require 'weborb/context'
require 'weborb/log'
require 'rbconfig'
require 'set'
require_dependency 'dashboard_layout'

# XXX: This service needs permissions checks.

class DashboardService
  def getDashboards(user)
    ar = []
    begin
      db = Dashboard.find_all_by_user_id(user.id, :order => 'dashboards.position, dashboard_dashboard_widgets.position', :include => [:dashboard_layout, {:dashboard_dashboard_widgets => {:dashboard_widget => :visualization_type}}])
    rescue  # this code was written to avoid the problem of transitioning from having dashboard to no dashboards because the SQL code Rails emits does not use an outer join...
      db = Dashboard.find_all_by_user_id(user.id)
    end
    ar.push(db)
    folders = Folder.find_all_by_user_id(user.id)
    dfolders = {}
    folders.each { |f| dfolders[f.id] = DashboardFolder.find_all_by_folder_id(f.id) }
    id_list = []
    folders.each { |f| id_list.push(f.id) }

    if id_list.length() > 0
      _sql = "SELECT id, folder_id, parent_id FROM dashboard_hierarchies WHERE folder_id in (#{id_list.join(',')}) ORDER BY dashboard_hierarchies.parent_id ASC"
      dh = DashboardHierarchy.new
      hfolders = []
      result = dh.connection.execute(_sql)
      while (aRow = result.fetch_row())
          begin
            dh = DashboardHierarchy.new
            dh.id = aRow[0]
            dh.folder_id = aRow[1]
            dh.parent_id = aRow[2]
            hfolders.push(dh)
          rescue
          end
      end
    end

    ar.push(folders)
    ar.push(dfolders)
    ar.push(hfolders)
  end
  
  def getDashboardLayouts
    DashboardLayout.find(:all, :order =>'id')
  end
  
  def saveDashboard(dashboard_to_save)
    if dashboard_to_save.save then
      {:success => true, :dashboard_saved => dashboard_to_save}
    else
      {:success => false, :errors =>dashboard_to_save.errors.full_messages}
    end
  end
  
  def moveDashboard(user_id, old_pos, new_pos)
    dashboard_to_move = Dashboard.find_by_user_id_and_position(user_id, old_pos)
    if(dashboard_to_move.nil? || !dashboard_to_move.insert_at(new_pos))
      {:success => false}
    else
      {:success => true, :dashboard_moved => dashboard_to_move, :old_pos => old_pos, :new_pos => new_pos}
    end
  end
  
  def removeDashboard(user_id, pos)
    dashboard_to_remove = Dashboard.find_by_user_id_and_position(user_id, pos)
    if(dashboard_to_remove.nil?)
      {:success => false}
    else
      dashboard_to_remove.destroy
      {:success => true, :dashboard_removed => dashboard_to_remove}
    end
  end
  
  def renameDashboard(user_id, pos, new_name)
    dashboard_to_rename = Dashboard.find_by_user_id_and_position(user_id, pos)
    if(dashboard_to_rename.nil?)
      {:success => false}
    else
      dashboard_to_rename.name = new_name
      if (dashboard_to_rename.save)
        {:success => true, :dashboard_renamed => dashboard_to_rename}
      else
        {:success => false, :errors =>dashboard_to_rename.errors.full_messages}
      end
    end
  end
  
  def addWidget(dashboard_id, widget_id, position)
    existing = DashboardDashboardWidget.find_by_dashboard_id_and_position(dashboard_id, position)
    if !existing.nil? then
      existing.destroy
    end
    dashboard_dashboard_widget = DashboardDashboardWidget.new
    dashboard_dashboard_widget.dashboard_widget_id = widget_id
    dashboard_dashboard_widget.dashboard_id = dashboard_id
    dashboard_dashboard_widget.position = position
    dashboard_dashboard_widget.save!
  end

  def moveWidget(dashboard_id, old_position, new_position)
    moving = DashboardDashboardWidget.find_by_dashboard_id_and_position(dashboard_id, old_position)
    existing = DashboardDashboardWidget.find_by_dashboard_id_and_position(dashboard_id, new_position)
    if !existing.nil? then
      existing.position = old_position
      existing.save!
    end
    moving.position = new_position
    moving.save!
  end
  
  def removeWidget(dashboard_id, position)
    removing = DashboardDashboardWidget.find_by_dashboard_id_and_position(dashboard_id, position)
    removing.destroy unless removing.nil?
    nil
  end
end

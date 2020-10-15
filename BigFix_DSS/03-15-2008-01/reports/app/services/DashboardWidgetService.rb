require 'weborb/context'
require 'weborb/log'
require 'rbconfig'
require 'set'

# XXX: This service needs permissions checks.

class DashboardWidgetService
	def getLibrary(user)
		DashboardWidget.find_all_by_user_id(user.id, :include => [:user, :visualization_type], :order => 'dashboard_widgets.name')
	end

	def save(widget)
		if widget.save then
			{:success => true, :widget => widget}
		else
			{:success => false}
		end
	end
	
	def destroy(widget)
	  widget.destroy  # Associations with dashboards will be implicitly destroyed.
	  { :success => true }
  end
end

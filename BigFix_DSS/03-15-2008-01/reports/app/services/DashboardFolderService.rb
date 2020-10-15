require 'weborb/context'
require 'weborb/log'
require 'rbconfig'
require 'set'
require_dependency 'flex_only_classes'

class DashboardFolderService
    def updateDashboardFolder(args)
        result = WebOrbResult.new
        result.info = "DashboardFolderService::updateDashboardFolder"
        result.status = -1
        result.statusMsg = "Invalid args sent to updateDashboardFolder !"  
        if (args.class.to_s == "Array") && (args.length == 4)
            result.status = 0
            result.statusMsg = ""  
            
            uid = args[0]
            i = args[1]
            fName = args[2]
            folder_id = args[3]

            fList = Folder.find_all_by_folder_id(folder_id)
            f = fList[0]
            f.name = fName
            f.save!
        end
        
        result
    end

    def insertDashboardFolder(args)
        result = WebOrbResult.new
        result.info = "DashboardFolderService::insertDashboardFolder"
        result.status = -1
        result.statusMsg = "Invalid args sent to insertDashboardFolder !"  
        if (args.class.to_s == "Array") && (args.length == 4)
            result.status = 0
            result.statusMsg = ""  
            
            uid = args[0]
            i = args[1]
            fName = args[2]
            folder_id = args[3]

            f = Folder.new
            f.user_id = uid
            f.name = fName
            f.save!

            dh = DashboardHierarchy.new
            dh.folder_id = f.id
            dh.parent_id = folder_id.id
            dh.save!
        end
        
        result
    end

    def reparentDashboardFolder(args)
        result = WebOrbResult.new
        result.info = "DashboardFolderService::reparentDashboardFolder"
        result.status = -1
        result.statusMsg = "Invalid args sent to reparentDashboardFolder !"  
        if (args.class.to_s == "Array") && (args.length == 3)
            result.status = 0
            result.statusMsg = ""  
            
            folder = args[0]
            dashboard = args[1]
            dashboard_localname = args[2];
            
            if (dashboard_localname == 'folder')
              _folder_id = dashboard.root().attribute("id")
              _parent_id = folder.root().attribute("id")

              _sql = "INSERT INTO dashboard_hierarchies (folder_id, parent_id) VALUES (#{_folder_id},#{_parent_id})"
              dh = DashboardHierarchy.new
              dh.connection.execute(_sql)
            else # must be a dashboard since it is not a folder...
              _folder_id = folder.root().attribute("id")
              _dashboard_id = dashboard.root().attribute("id")

              _sql = "INSERT INTO dashboard_folders (folder_id, dashboard_id) VALUES (#{_folder_id},#{_dashboard_id})"
              df = DashboardFolder.new
              df.connection.execute(_sql)
            end
        end
        
        result
    end
end
  
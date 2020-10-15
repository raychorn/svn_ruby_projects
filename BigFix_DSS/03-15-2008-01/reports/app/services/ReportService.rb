require 'weborb/context'
require 'weborb/log'
require 'rbconfig'
require 'set'
require_dependency 'flex_only_classes'

class ReportService
    def getReportsForUser(args)
        result = WebOrbResult.new
        result.info = "ReportService::getReportsForUser"
        result.status = -1
        result.statusMsg = "Invalid args sent to getReportsForUser !"  
        if (args.class.to_s == "Array") && (args.length == 1)
            result.status = 0
            result.statusMsg = ""  
            
            userID = args[0]
            result.data = Report.find_all_by_user_id(userID)
            end
        
        result
	end

    def getReports(user)
        Report.find_all_by_user_id(user.id)
    end
    
    def setSchedule(report_id, schedule)
      report = Report.find(report_id)
        
      tm = Time.new
      report.next_scheduled_run = schedule.to_s.gsub("US-Eastern", tm.zone)
      report.save!
    end
end

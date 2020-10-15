require 'weborb/context'
require 'weborb/log'
require 'rbconfig'
require 'flex_only_classes'
require 'set'

class ReportService
    def getReports(user)
        Report.find_all_by_user_id(user.id)
    end
    
    def setSchedule(report_id, schedule)
      #add error checking later, might want to make this part of a separate ScheduledReports service
      reportScheduleToAdd=ReportSchedule.find_by_report_id(report_id)
      if(reportScheduleToAdd.nil?)
        reportScheduleToAdd=ReportSchedule.new
      end
      reportScheduleToAdd.schedule=schedule
      reportScheduleToAdd.report_id=report_id
      reportScheduleToAdd.save!
    end
end

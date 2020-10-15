class ReportSchedule < ActiveRecord::Base
  belongs_to :report
  validates_presence_of :schedule
end

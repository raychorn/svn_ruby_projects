class ReportSubjectProperty < ActiveRecord::Base
	belongs_to :ReportSubject
	belongs_to :PropertyType
end

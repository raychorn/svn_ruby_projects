class ReportSubject < ActiveRecord::Base
	has_and_belongs_to_many :report_delta_types
	has_and_belongs_to_many :report_metrics
	has_many :ReportSubjectProperties
	has_many :AllProperties
	has_many :ComputerGroupDistributions
	has_many :AllComputerGroupDistributions
end

require 'weborb/context'
require 'weborb/log'
require 'rbconfig'
require 'set'

class ReportingCatalog
	def initialize()
		@dbh = ActiveRecord::Base.connection
	end

	# I don't think we use this anymore...
	def getMetricsGroupedBySubject()
		ReportSubject.find(
			:all,
			:conditions => ['report_metrics_report_subjects.group_by = true'],
			:include => :report_metrics,
			:order => 'report_subjects.name, report_metrics.name'
		).collect do |report_subject|
			{
				:subject_id => report_subject.id,
				:subject_name => report_subject.name,
				:metrics => report_subject.report_metrics.collect do |metric|
					{
						:metric_id => metric.id,
						:metric_name => metric.name
					}
				end
			}
		end
	end


	# I don't think we use this anymore
	def getFilterLibrary(subject_id, include_computer_props = true)
		subject_properties = (ReportSubjectProperty.find_all_by_report_subject_id(subject_id)).sort do |a, b| a.name <=> b.name end
		computer_properties = (Property.find(:all) + ReportSubjectProperty.find_all_by_report_subject_id(6)).sort do |a, b| a.name <=> b.name end
		property_operators = PropertyTypeOperator.find(:all)
		properties = [{:id => nil, :name => 'Computer Properties'}] + computer_properties
		properties += [{:id => nil, :name => "#{ReportSubject.find(subject_id).name}  Properties"}] + subject_properties
		if include_computer_props then
			{:properties => properties, :property_operators => property_operators}
		else
			{:properties => subject_properties, :property_operators => property_operators}
		end
	end

	def getCatalog()
		subjects = ReportSubject.find(
			:all,
			# in the flex component for trend subject/metric, we simply ignore all subjects with no metrics...
			:conditions => ['report_metrics_report_subjects.group_by = true OR report_metrics_report_subjects.group_by is NULL'],
			:include => [:report_metrics, :AllProperties],
			:order => 'report_subjects.name, report_metrics.name, all_properties.name'
		)
		property_operators = PropertyTypeOperator.find(:all, :order => 'name')
		visualization_types = VisualizationType.find(:all, :order => 'name')
		computer_group_distributions = AllComputerGroupDistribution.find(:all, :order => 'name')
		aggregate_functions = AggregateFunction.find(:all, :order => 'name')

		{
		  :subjects => subjects, 
		  :property_operators => property_operators, 
		  :visualization_types => visualization_types,
		  :computer_group_distributions => computer_group_distributions,
		  :aggregate_functions => aggregate_functions
		}
	end
end
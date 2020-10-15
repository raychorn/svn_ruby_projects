require 'weborb/context'
require 'weborb/log'
require 'rbconfig'
require 'set'

class SearchService
	def initialize
		super
		@dbh = ActiveRecord::Base.connection
	end

	def autoComplete(args)
		if args.property.nil? || args.search_string.nil?
			return {:success => false, :message => "You must choose a property and specify a search string"}
		end
		if (args.property.source_table == 'report_subject_properties') then
			realProperty = ReportSubjectProperty.find(args.property.id)
			matching_records = realProperty.ar_class.classify.constantize.find(:all, :conditions => ['lower(name) like ?', '%' + args.search_string.downcase + '%'], :limit => 5)
		else
			# we should never receive a property which is not a report_subject_property
		end
		return {:success => true, :matching_records => matching_records}
	end
end
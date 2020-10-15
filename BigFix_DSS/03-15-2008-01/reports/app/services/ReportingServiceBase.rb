class ReportingServiceBase
	SubjectVuln = 2
	SubjectPolicy = 3
	SubjectDLP = 4
	SubjectVirus = 5

	def initialize()
		@dbh = ActiveRecord::Base.connection
	end

	def getSubjects()
		@dbh.select_all("select * from report_subjects where id NOT IN (1,6)")
	end

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
end
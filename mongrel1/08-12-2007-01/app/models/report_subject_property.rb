class ReportSubjectProperty < ActiveRecord::Base
	belongs_to :ReportSubject
	belongs_to :PropertyType

	def picker
		case id
			when 1 then
				'VulnerabilityPicker'
			when 2 then
				'ApplicationPicker'
			when 5 then
				{:true_label => 'Remotely Exploitable', :false_label => 'Locally Exploitable'}
			when 6 then
				'PolicyPicker'
			when 8 then
				'PlatformPicker'
			when 9 then
				'DLPPicker'
			when 11 then
				DLPSeverity.find(:all)
			when 12 then
				'VirusPicker'
			when 13 then
				['foo','bar','baz']
			when 15 then
				'OperatingSystemPicker'
			else
				nil
		end
	end

	def clone_attributes(reader_method = :read_attribute, attributes = {})
		[:picker].each do |attr|
			attributes[attr.to_s] = self.send(attr)
		end

		super(reader_method, attributes)
	end
end

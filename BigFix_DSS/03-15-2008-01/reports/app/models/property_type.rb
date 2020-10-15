class PropertyType < ActiveRecord::Base
	has_many :ReportSubjectProperties
	has_many :PropertyTypeOperators
	has_many :Properties
	has_many :AllProperties
end

class Property < ActiveRecord::Base
	belongs_to :PropertyType
	has_many :PropertyTypeOperators, :through => :PropertyType
	validates_presence_of :name

	def self.lookup(property)
		@@properties ||= self.find(:all).index_by { |obj| obj.name.downcase.gsub(' ', '_').to_sym }

    raise NameError.new("No such property: #{property}") unless @@properties.has_key?(property)
		@@properties[property].id
	end
end

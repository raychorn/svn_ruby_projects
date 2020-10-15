require 'acts_as_temporal'
require 'editor_support'
class Computer < ActiveRecord::Base
	acts_as_temporal

  has_and_belongs_to_many :datasources
	has_and_belongs_to_many_temporal :computer_groups
	belongs_to_temporal :operating_system
	has_many_temporal :computer_vulns
	has_many_temporal :computer_apps
	has_many_temporal :computer_properties
	has_many_temporal :computer_benchmarks
	has_many_temporal :benchmark_check_results
	
	has_many :contact_relationships, :class_name => 'ComputerContact', :table_name => 'computers_contacts'
	
	editable

	alias_method :apps, :computer_apps
	alias_method :vulns, :computer_vulns
	alias_method :properties, :computer_properties
	alias_method :groups, :computer_groups

	def ip_address
		property_value :ip_address
	end

	def netbios_name
		property_value :netbios_name
	end

	def dns_name
		property_value :dns_name
	end

	def os_name
		operating_system.name
	end

	def property_value(property)
		property_id = case property
		  when Symbol
		    Property.lookup(property)
		  else
		    property
	    end
	    
		p = computer_properties.to_a.find { |p| p.property_id == property_id }
		unless p.nil?
			p.value
		end
	end

	def clone_attributes(reader_method = :read_attribute, attributes = {})
		[:os_name, :ip_address, :netbios_name, :dns_name].each do |attr|
			attributes[attr.to_s] = self.send(attr)
		end

		super(reader_method, attributes)
	end
end

class AllProperty < ActiveRecord::Base
	belongs_to :PropertyType

	def picker
		case id
			when 5 then
				{:true_label => 'Remotely Exploitable', :false_label => 'Locally Exploitable'}
			when 11 then
				DLPSeverity.find(:all)
			when 13 then
				MalwareType.find(:all)
			when 34 then
			  VulnSeverity.find(:all)
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

  def deep_copy
    Marshal.load(Marshal.dump(self))
  end

  # MySQL views consisting of unioned boolean (aka tinyint(1)) columns don't actually register as tinyint(1)  
  # so we need to override the getters here...
	def is_aggregate
	  if read_attribute(:is_aggregate) == 0 then
	    false
	  else
	    true
	  end
	end
	def is_default
	  if read_attribute(:is_default) == 0 then
	    false
	  else
	    true
	  end
	end
	def is_enum
	  if read_attribute(:is_enum) == 0 then
	    false
	  else
	    true
	  end
	end
end

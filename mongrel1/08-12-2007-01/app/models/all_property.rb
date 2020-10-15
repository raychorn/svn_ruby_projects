class AllProperty < ActiveRecord::Base
	belongs_to :PropertyType

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

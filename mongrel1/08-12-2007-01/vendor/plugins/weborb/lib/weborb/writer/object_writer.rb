require 'weborb/mapping'
require 'weborb/log'

class ObjectWriter
  def write_object( object, formatter )
    object_class = object.class
	class_name = object_class.name
	resolved_name = Mapping.get_client_class( class_name )
	
	if Log.info?
      Log.info( "writing object of type: " + class_name + " resolved to " + resolved_name )
    end
	
	object_fields = Hash.new
	object_fields[ "_orbclassname" ] = resolved_name
	attributes = object_class.get_attributes
	
	attributes.each do |attribute|
	  attr_name = attribute.id2name
	  attr_method = object.method attr_name
	  attr_value = attr_method.call
	  object_fields[attr_name] = attr_value
	end
	
	object_serializer = formatter.get_object_serializer
	object_serializer.write_object( resolved_name, object_fields, formatter )
  end
end
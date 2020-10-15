require 'weborb/writer/message_writer'

class ObjectSerializer

  def write_object( class_name, object_fields, formatter )
	
	if class_name.nil?
   	  formatter.begin_write_object_map( object_fields.length )	  
	else
	  formatter.begin_write_named_object( class_name, object_fields.length )
	end
	
	object_fields.each do |key, value| 
      formatter.write_field_name key.to_s
      MessageWriter.write_object( value, formatter )
    end
    
    formatter.end_write_object
    
  end
end
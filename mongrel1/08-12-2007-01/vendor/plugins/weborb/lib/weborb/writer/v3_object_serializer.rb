require 'weborb/writer/message_writer'
require 'weborb/log'

class V3ObjectSerializer

  def write_object( class_name, object_fields, formatter )
    object_fields.delete( "_orbclassname" )
	formatter.begin_write_named_object( class_name, object_fields.length )
	object_fields.each_key {| key | formatter.write_field_name key.to_s }
		
	object_fields.each do |key, value| 
      
      if Log.debug?
        Log.debug( "serializing property/field : " + key.inspect + " value: " + value.to_s )
      end

      field_name = key
      formatter.begin_write_field_value
      
      begin
        MessageWriter.write_object( value, formatter )
      rescue Exception => exception
		puts "exception writing field: " + field_name + " message: " + exception.message + " stack trace:\n" + exception.backtrace.join("\n")
      ensure
        formatter.end_write_field_value
      end
    end	
    
    formatter.end_write_object
  end
end

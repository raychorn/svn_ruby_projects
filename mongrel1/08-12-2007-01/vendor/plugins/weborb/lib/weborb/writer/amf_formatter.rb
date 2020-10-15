require 'weborb/constants'
require 'weborb/io/binary_writer'

class AmfFormatter

  def initialize( binary_writer, object_serializer )
    @writer = binary_writer
    @object_serializer = object_serializer
  end
  
  def get_object_serializer
    @object_serializer
  end
  
  def write_message_version( version )
    @writer.write_short( version )
  end

  def direct_write_short( s )
    @writer.write_short( s )
  end

  def direct_write_string( string )
    @writer.write_utf( string, false )
  end
 
  def direct_write_boolean( boolean )
    if boolean
      @writer.write_byte 1
    else
      @writer.write_byte 0
    end
  end

  def direct_write_int( integer )
    @writer.write_int( integer )
  end
  
  def end_write_array
  end
  
  def begin_write_field_value
  end  
  
  def end_write_field_value
  end  
  
  def get_bytes
    @writer.bytes
  end
  
  def cleanup
  end
end
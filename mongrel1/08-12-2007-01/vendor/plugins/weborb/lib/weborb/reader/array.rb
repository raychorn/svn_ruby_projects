require 'weborb/io/binary_reader'
require 'weborb/formats/parse_context'
require 'weborb/formats/amf_request_parser'

class ArrayReader
  def read( reader, parse_context )
    length = reader.read_integer
	array = Array.new
	parse_context.add_reference( array )

    while length > 0
      data = AmfRequestParser.read_data( reader, parse_context )
      array.push data
      length = length - 1
    end

    array
  end
end

class V3ArrayReader
  
  def initialize 
    @string_reader = V3StringReader.new
  end

  def read( reader, parse_context )
    ref_id = reader.read_var_integer

	if( (ref_id & 0x1) == 0 )
	  parse_context.get_reference( ref_id >> 1 )
	else 
	  array_size = ref_id >> 1
	  adapting_type = nil
	  container = nil
		
	  while( true )
	    str = @string_reader.read( reader, parse_context )
        break if( str.nil? || str.length == 0 )

        if container.nil?
		  adapting_type = AnonymousObject.new()
		  container = adapting_type
		  parse_context.add_reference( adapting_type )
		end

		obj = AmfRequestParser.read_data( reader, parse_context )
		container[ str ] = obj
      end
      
      if adapting_type.nil?
		container = Array.new array_size
		adapting_type = container
		parse_context.add_reference( adapting_type )

		for i in 0...array_size
		  container[ i ] = AmfRequestParser.read_data( reader, parse_context )
		end
	  else
		for i in 0...array_size
		  obj = AmfRequestParser.read_data( reader, parse_context )
		  container[ i.to_s ] = obj
		end
      end

	  adapting_type		
	end
  end
end
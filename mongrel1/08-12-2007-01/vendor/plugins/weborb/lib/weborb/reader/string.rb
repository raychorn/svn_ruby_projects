require 'weborb/io/binary_reader'
require 'weborb/formats/parse_context'

class StringType

  def initialize(value)
    @value = value
  end
  
  def default_adapt
    @value
  end 

end

class UTFStringReader
  def read( reader, parse_context )
	reader.read_utf
  end
end

class LongUTFStringReader
  def read( reader, parse_context )
    reader.read_string(reader.read_integer)
  end
end

class V3StringReader
  def read( reader, parse_context )
    len = reader.read_var_integer

	if( (len & 0x1) == 0 )
	  parse_context.get_string_reference( len >> 1 )
	else  
      str = reader.read_utf( len >> 1 )

	  if( str.length == 0 )
		str
	  else	
		parse_context.add_string_reference( str )
		str
	  end
	end
  end
end
require 'weborb/io/binary_reader'
require 'weborb/formats/parse_context'

class NumberObject
  def initialize( value )
    @value = value
  end
  
  def default_adapt
    @value
  end
end

class NumberReader

  def read( reader, parse_context )
	reader.read_double
  end
  
end

class IntegerReader
  def read( reader, parse_context )
	(reader.read_var_integer << 3) >> 3
  end
end
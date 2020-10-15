require 'weborb/io/binary_reader'
require 'weborb/formats/parse_context'
require 'weborb/reader/null'

class UndefinedType

  def default_adapt
    nil
  end 

end

class UndefinedReader

  def read( reader, parse_context )
	NullType.new
  end
  
end
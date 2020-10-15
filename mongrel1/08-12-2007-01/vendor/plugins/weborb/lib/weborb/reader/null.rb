require 'weborb/io/binary_reader'
require 'weborb/formats/parse_context'

class NullType

  def default_adapt
    nil
  end 

end

class NullReader

  def read( reader, parse_context )
	nil
  end
  
end
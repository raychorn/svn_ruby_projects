require 'weborb/io/binary_reader'
require 'weborb/formats/parse_context'

class PointerReader

  def read( reader, parse_context )
    pointer = reader.read_unsigned_short
	parse_context.get_reference( pointer )
  end
end
require 'weborb/io/binary_reader'
require 'weborb/formats/parse_context'

class V3Reader
  
  def read( reader, parse_context )
    new_parse_context = ParseContext.new(3)
	AmfRequestParser.read_data( reader, new_parse_context, -1, 3 )
  end
end
require 'weborb/io/binary_reader'
require 'weborb/formats/parse_context'
require 'rexml/document'

class XmlType

  def initialize( document )
    @document = document
  end
  
  def default_adapt
    @document
  end 

end

class XmlReader

  def read( reader, parse_context )
    REXML::Document.new(reader.read_string(reader.read_integer))
  end
end

class V3XmlReader

  def read( reader, parse_context )
    length = reader.read_var_integer
    return parse_context.get_reference( length >> 1 ) if( (length & 0x1) == 0 )
    length = length >> 1
    document = REXML::Document.new(reader.read_utf( length ))
	parse_context.add_reference( document )
	document
  end
end

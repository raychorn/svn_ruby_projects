require 'weborb/formats/amf_request_parser'

class ParserFactory

  def ParserFactory.getParser
    AmfRequestParser.new
  end
end
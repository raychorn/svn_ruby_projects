require 'weborb/io/binary_reader'
require 'weborb/formats/parse_context'
require 'weborb/formats/amf_request_parser'

class RemoteReferenceObject

  def initialize( reference )
    @reference = reference
  end  
  
  def default_adapt
    @reference
  end 

end

class RemoteReferenceReader

  def read( reader, parse_context )
    object_name = reader.read_utf
	reference = AmfRequestParser.read_data( reader, parse_context )

	if reference.nil?
	  nil
    else
	  hosting_env_id = reader.read_utf
	  RemoteReferenceObject.new( reference )
	end
  end
  
end
require 'weborb/constants'
require 'weborb/io/binary_reader'
require 'weborb/formats/parse_context'
require 'weborb/formats/amf_request_parser'

class AnonymousObject < Hash
  attr_accessor :full_name, :internal_id
  
  def properties
    self
  end  
   
  def default_adapt
    self
  end
  
  def method_missing(method_symbol)
    method_name = method_symbol.id2name
    
    if self.has_key?( method_name )
      self[method_name]
    else
      super(method_symbol)
    end
  end

end

class AnonymousObjectReader

  def read( reader, parse_context )
	anonymous_object = AnonymousObject.new()
	parse_context.add_reference( anonymous_object )
  
    while( true )
      prop_name = reader.read_utf
	  obj = nil
      data_type = reader.read_byte
      
      if( data_type == Datatypes::REMOTEREFERENCE_DATATYPE_V1 && prop_name != "nc" )
		obj = 0
	  else
		obj = AmfRequestParser.read_data( reader, parse_context, data_type )
	  end

	  if obj.nil? 
	     break
	  end

      anonymous_object.store( prop_name, obj )
    end
  
    if( anonymous_object.length == 1 && anonymous_object.has_key?( "nc" ) )
      anonymous_object[ "nc" ]
    else
      anonymous_object
    end
  end
  
end

class BoundPropertyBagReader
  
  def read( reader, parse_context )
	anonymous_object = AnonymousObject.new()
	parse_context.add_reference( anonymous_object )
  
    while( true )
      prop_name = reader.read_utf
	  obj = AmfRequestParser.read_data( reader, parse_context )
		
      if obj.nil? 
	     break
	  end

	  anonymous_object.store( prop_name, obj )
    end

	anonymous_object
  end
end
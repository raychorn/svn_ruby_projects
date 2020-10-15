require 'weborb/formats/amf_request_parser'
require 'weborb/writer/message_writer'
require 'weborb/config/weborb_config'
require 'amf3'

module AMF3Hook
  def AMF3Hook.transform_object(o)
    case o
    when BodyHolder
      [nil, o.body]
    when ActiveRecord::Base
      # Borrowed from WebORB... need to clean up
      properties = o.attributes
      instance_variables = o.instance_variables
      instance_variables.each do |instance_variable|
        method_name = instance_variable.delete "@"
        next if(method_name == "attributes" or method_name == "new_record" or method_name == "new_record_before_save" or method_name == "errors" )

        if o.respond_to?( method_name )
          method = o.method method_name
          model_data = method.call
          properties.store( method_name, model_data )
        else
          Log.debug( "active record object does not respond to the method: " + method_name ) if Log.debug?
        end
      end

      object_class = o.class
      attributes = object_class.get_attributes

      attributes.each do |attribute|
        attr_name = attribute.id2name
        attr_method = o.method attr_name
        attr_value = attr_method.call
        properties.store( attr_name, attr_value )
      end

      class_name = o.class.name
      server_mappings = WebORBConfig.get_server_mappings
      resolved_name = server_mappings[class_name]

      return [resolved_name, properties]
    else
      nil
    end
  end
end

class MessageWriter
  def self.write_object(value, formatter)
    o = ''
    mapping = Hash.new { |h, k| k }
    mapping.update(WebORBConfig.get_server_mappings)
    writer = AMF3::Writer.new(o, mapping, AMF3Hook.method(:transform_object))
    writer << value
    writer.flush
    bytes = formatter.get_bytes
    o.each_byte { |b| bytes << b }
  end
end

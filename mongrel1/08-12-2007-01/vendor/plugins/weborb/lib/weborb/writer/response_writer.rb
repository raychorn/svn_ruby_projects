require 'weborb/writer/message_writer'

class ResponseWriter

  def ResponseWriter.write( message, formatter )
    formatter.write_message_version( message.version )
    headers = message.response_headers
    formatter.direct_write_short( headers.length )

    for i in 0...headers.length
      header = headers[i]
      formatter.direct_write_string( header.header_name )
      formatter.direct_write_boolean( header.must_understand )
      formatter.direct_write_int( -1 )
      MessageWriter.write_object( header.header_value, formatter )
    end
	
	bodies = message.body_parts
	formatter.direct_write_short( bodies.length )
	
	for j in 0...bodies.length
      body = bodies[j]
      formatter.direct_write_string( body.response_uri.nil? ? "null" : body.response_uri )
      formatter.direct_write_string( body.service_uri.nil? ? "null" : body.service_uri )
      formatter.direct_write_int( -1 );
      formatter.begin_write_body_content
      MessageWriter.write_object( body.response_data_object, formatter )
      formatter.end_write_body_content
	end		
			
  end
end
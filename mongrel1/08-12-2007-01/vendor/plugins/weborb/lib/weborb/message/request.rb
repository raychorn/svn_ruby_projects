class Header
	attr_reader :header_name, :must_understand, :header_value
	
	def initialize( header_name, must_understand, header_value )
		@header_name = header_name
		@must_understand = must_understand
		@header_value = header_value
	end
end

class Body
  attr_accessor :service_uri, :response_uri, :data_object, :response_data_object
  
  def initialize( service_uri, response_uri, data_object )
	@service_uri = service_uri
	@response_uri = response_uri
	@data_object = data_object
  end
end

class Request
	attr_accessor :version, :body_parts, :formatter, :response_headers
	@@instancesCreated = 0
	
	def initialize( version, headers, body_parts, formatter )
		@@instancesCreated = @@instancesCreated + 1
		@version = version
		@headers = headers
		@body_parts = body_parts
		@formatter = formatter
		@response_headers = Array.new
	end
	
	def get_initial_request_uri
	  @body_parts[0].service_uri
	end
	
	def get_initial_request_body
	  @body_parts[0].data_object
	end
end
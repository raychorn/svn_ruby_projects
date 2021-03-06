require 'weborb/log'
require 'weborb/constants'
require 'weborb/mapping'
require 'weborb/handler/object_handler'

class Invoker

  def Invoker.init_handlers
    @@handler = ObjectHandler.new
  end 
  
  def dispatch( request_message )
    
    invocations = request_message.body_parts

    for i in 0...invocations.length
      begin
        invocation_body = invocations[i]
        request_uri = invocation_body.service_uri
        end_index = request_uri.rindex '.'
	target_class = request_uri.slice(0, end_index)
	function = request_uri.slice( target_class.length + 1, request_uri.length - 1 );
	arguments = invocation_body.data_object
	return_value = Invoker.handle_invoke( request_message, target_class, function, arguments )
	invocation_body.response_data_object = return_value
	invocation_body.service_uri = ""
	invocation_body.response_uri << Constants::ONRESULT
      rescue Exception => exception
      	if Log.error?
          message = "Exception processing request.  Class: " + target_class + ", function " + function + ", message: " + exception.message + "\n" + exception.backtrace.join("\n")
          Log.error( message )
        end
      	
      	invocation_body.response_data_object = exception
      	invocation_body.service_uri = ""
	invocation_body.response_uri << Constants::ONSTATUS
      end
    end
    
    true
  end
  
  def Invoker.handle_invoke( request_message, target_class, function, arguments )
    resolved_name = Mapping.get_service_mapping( target_class )
    @@handler.handle_invoke( request_message, resolved_name, function, arguments )
  end
end

Invoker.init_handlers
require 'weborb/dispatcher/invoker'
require 'weborb/dispatcher/v3dispatcher'

class WebOrbDispatcher

  def WebOrbDispatcher.init_dispatchers
    @@dispatchers = Array.new
    WebOrbDispatcher.add_dispatcher V3Dispatcher.new
    WebOrbDispatcher.add_dispatcher Invoker.new
  end
  
  def WebOrbDispatcher.add_dispatcher( dispatcher )
    @@dispatchers.push dispatcher
  end
  
  def WebOrbDispatcher.dispatch( request_message )
    processed = false
    
    for i in 0...@@dispatchers.length
      if @@dispatchers[i].dispatch request_message
        processed = true
        break
      end
    end
    
    processed
  end
end

WebOrbDispatcher.init_dispatchers
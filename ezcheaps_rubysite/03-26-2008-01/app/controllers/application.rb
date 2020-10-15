# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '5f6171e9314ebc3a73f56e48af75f012'
  def rescue_action_in_public(exception)
    render :text => "<html><body><p>
The requested page cannot be displayed.</p>
<!--  #{exception}  --></body></html>" 
  end
  def local_request?
    false
  end
  def rescue_action_in_public2(exception)
    render :template => "controller/404" 
  end
end

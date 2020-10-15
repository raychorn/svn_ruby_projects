class RequestContext

  def RequestContext.set_context( request, session )
    @@request = request
    @@session = session
  end
  
  def RequestContext.set_session( session )
    @@session = session
  end
  
  def RequestContext.get_session
    @@session
  end
  
  def RequestContext.set_request( request )
    @@request = request
  end
  
  def RequestContext.get_request
    @@request
  end  
  
  def RequestContext.set_credentials( user_name, password )
    @@session['weborb_flex_user_name'] = user_name
    @@session['weborb_flex_password'] = password
  end 
  
  def RequestContext.get_user_name
    @@session['weborb_flex_user_name']
  end 
  
  def RequestContext.get_password
    @@session['weborb_flex_password']
  end 
end
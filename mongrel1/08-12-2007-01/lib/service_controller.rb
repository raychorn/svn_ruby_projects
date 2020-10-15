# This parent class for weborb services lets them take advantage of some of the
# features available to regular controllers, such as AuthenticatedSystem and
# direct access to the session.  The "session=" method allows a fake session to
# be substituted for offline testing.

class ServiceController
  include Reloadable
  
  def self.helper_method *args
  end
  include AuthenticatedSystem

  def session
    @session ||= RequestContext.get_session
  end
  
  def session=(session)
    @session = session
  end
end


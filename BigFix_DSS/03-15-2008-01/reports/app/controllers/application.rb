# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
    # Pick a unique cookie name to distinguish our session data from others'
    session :session_key => '_reports_session_id'

    # Restful Authentication
    include AuthenticatedSystem
    before_filter :login_from_cookie
end

module DSSConstants
  PropertyTypeID = 1
  PropertyTypeString = 2
  PropertyTypeNumber = 3
  PropertyTypeIP = 4
  PropertyTypeTime = 5
  PropertyTypeBoolean = 6
  
  PropertyType_ID_Operator_IsInSet = 1
  PropertyType_String_Operator_Is = 5
  PropertyType_Number_Operator_Equals = 12
  PropertyType_IP_Operator_Is = 16
  PropertyType_Boolean_Operator_Is = 20
end


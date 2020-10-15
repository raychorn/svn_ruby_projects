require 'weborb/v3types/AckMessage'

class ErrMessage < AckMessage
  attr_accessor :rootCause, :faultString, :faultCode, :extendedData, :faultDetail
  
  def initialize( correlationId, exception )
    super( correlationId, nil, nil )
    self.faultCode = "Server.Processing"
    self.faultString = exception.message;
    self.faultDetail = "details not available"
    self.isError = true
  end
end
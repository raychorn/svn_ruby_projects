require 'uuidtools'
require 'weborb/util'
require 'weborb/v3types/v3message'

class AckMessage < V3Message
  
  def initialize(correlationId, clientId, obj)
    self.correlationId = correlationId
    self.clientId = clientId.nil? ? UUID.random_create.to_s.upcase : clientId
    self.messageId = UUID.random_create.to_s.upcase

    self.headers = Hash.new
	self.timestamp = TimeUtil.time_in_milliseconds 
	self.body = BodyHolder.new
    self.body.body = obj
    self.timeToLive = 0
    self.isError = false
  end
end


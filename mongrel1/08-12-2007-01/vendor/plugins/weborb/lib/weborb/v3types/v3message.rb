class BodyHolder
  attr_accessor :body
end

class V3Message
  attr_accessor :correlationId, :timestamp, :body, :timeToLive, :destination, :messageId, :clientId, :headers

  def isError
    @is_error = false if @is_error.nil?
    @is_error
  end
  
  def isError= is_error
    @is_error = is_error
  end
end
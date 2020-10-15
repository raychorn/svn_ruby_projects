class WebOrbResult
    attr_accessor :status, :type, :statusMsg
	
	def initialize
		@type = 'WebOrbResult'
		@status = -1
        @statusMsg = ''
	end
end

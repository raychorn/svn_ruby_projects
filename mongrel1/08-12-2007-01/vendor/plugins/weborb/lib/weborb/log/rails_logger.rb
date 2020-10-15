class RailsLogger
	def debug( message )
		RAILS_DEFAULT_LOGGER.debug "DEBUG: " + message
	end

	def info( message )
		RAILS_DEFAULT_LOGGER.info "INFO: " + message
	end

	def warn( message )
		RAILS_DEFAULT_LOGGER.warn "WARN: " + message
	end

	def error( message )
		RAILS_DEFAULT_LOGGER.error "ERROR: " + message
	end

	def fatal( message )
		RAILS_DEFAULT_LOGGER.fatal "FATAL: " + message
	end
end
class StdOutLogger
  def debug( message )
  	puts "DEBUG: " + message
  end
  
  def info( message )
  	puts "INFO: " + message
  end

  def warn( message )
  	puts "WARN: " + message
  end
  
  def error( message )
  	puts "ERROR: " + message
  end
  
  def fatal( message )
  	puts "FATAL: " + message
  end
end
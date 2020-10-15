require 'weborb/io/binary_reader'
require 'weborb/formats/parse_context'

class BooleanType

  def initialize(value)
    @value = value
  end
  
  def default_adapt
    @value
  end

end

class BooleanReader

  def initialize(initial_value=nil)
    if initial_value.nil?
      @initialized = false
    else
      @initialized = true
      @initial_value = initial_value
    end
  end

  def read( reader, parse_context )
	@initialized ? @initial_value : reader.read_boolean
  end
  
end
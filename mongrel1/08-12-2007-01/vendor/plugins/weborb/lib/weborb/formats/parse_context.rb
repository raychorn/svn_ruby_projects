class ParseContext
  attr_accessor :version
  
  def initialize(version=0)
    @version = version
    @references = Array.new
    @stringReferences = Array.new
    @class_infos = Array.new
  end

  def add_reference( adapting_type )
    @references.push adapting_type
  end
  
  def get_reference( pointer )
    @references[ pointer ]
  end
  
  def add_string_reference( refStr )
	@stringReferences.push refStr
  end

  def get_string_reference( index )
    @stringReferences[ index ]
  end
  
  def add_class_info_reference( object_val )
	@class_infos.push( object_val )
  end
  
  def get_class_info_reference( index )
	@class_infos[ index ]
  end
end
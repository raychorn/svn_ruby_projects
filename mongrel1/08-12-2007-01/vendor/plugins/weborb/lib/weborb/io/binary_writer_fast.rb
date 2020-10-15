class BinaryWriterFast
  attr_reader :bytes
  
  def initialize
    @bytes = String.new
	end
  
  def write_short( short )
	@bytes << ((short >> 8) & 0xFF)
	@bytes << (short & 0xFF)
  end
  
  def write_int( integer )
	@bytes << ((integer >> 24) & 0xFF)
	@bytes << ((integer >> 16) & 0xFF)
	@bytes << ((integer >> 8) & 0xFF)
	@bytes << (integer & 0xFF)
  end
  
  def write_double( number )
	@bytes << [number].pack('G')
  end
  
  def write_string( string )
	@bytes << string
  end
  
  def write_byte( byte )
	@bytes << byte
  end
  
  def write_utf( content, extendedutf=false, prepend_byte=false )
	  strLength = content.length
	  
	  if prepend_byte
		  @bytes << (strLength <= 65535 ? 2 : 12)
	  end
	  
	  if( extendedutf )
		  write_var_int( (strLength << 1 | 0x1) )
	  else
		  
		  if( strLength > 65535 )
			  @bytes << (strLength >> 24 & 0xFF)
			  @bytes << (strLength >> 16 & 0xFF)
		  end
		  
		  @bytes << (strLength >> 8 & 0xFF)
		  @bytes << (strLength & 0xFF)
	  end
	  
	  @bytes << content
  end
  
  def write_var_int( v )
	if( v < 128 )
	  @bytes << v
	elsif( v < 16384 )
	  @bytes << (v >> 7 & 0x7F | 0x80)
	  @bytes << (v & 0x7F)
	elsif( v < 2097152 )
	  @bytes << (v >> 14 & 0x7F | 0x80)
	  @bytes << (v >> 7 & 0x7F | 0x80)
	  @bytes << (v & 0x7F)
	elsif( v < 1073741824 )
	  @bytes << (v >> 22 & 0x7F | 0x80)
	  @bytes << (v >> 15 & 0x7F | 0x80)
	  @bytes << (v >> 8 & 0x7F | 0x80)
	  @bytes << (v & 0xFF)
    end
  end
end
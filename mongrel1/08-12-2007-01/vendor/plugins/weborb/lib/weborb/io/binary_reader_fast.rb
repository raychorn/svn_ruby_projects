class BinaryReaderFast
	
	def initialize( bytes )
		@bytes = bytes
		@index = 0
	end
	
	def read_unsigned_short
		byte1 = read_byte
		byte2 = read_byte
		(byte1 << 8) + byte2
	end
	
	def read_integer
		byte1 = read_byte
		byte2 = read_byte
		byte3 = read_byte
		byte4 = read_byte
		
		if byte4.nil?
			byte4 = 0
		end
		
		((byte1 << 24) + (byte2 << 16) + (byte3 << 8) + byte4)
	end
	
	def read_double
		bytes = Array.new(8);
		result = ""
		
		bytes.each do |byte|
			byte = read_byte
			byte = 0 if byte.nil?
			result << byte
		end
		
		double = result.unpack('G')
		double[0]
	end
	
	def read_boolean
		byte1 = read_byte
		byte1 != 0
	end
	
	def read_utf( len=nil )
		if len.nil?
			length = read_unsigned_short
			read_string( length )
		else
			string = ""
			bytes = read_bytes( len )
			i = 0; 
			
			while( i < len )
				c = bytes[ i ] & 0xFF
				code = c >> 4
				
				if( code >= 0 && code <= 7 )
					i += 1
					string << c.chr
				elsif( code == 12 || code == 13 )
					i += 2
					char2 = bytes[ i - 1 ]
					string << (c.chr + char2.chr)
				elsif( code == 14 )
					i += 3
					char2 = bytes[ i - 2 ]
					char3 = bytes[ i - 1 ]
					string << (c.chr + char2.chr + char3.chr)
				end
			end
			
			string
		end
	end
	
	
	def read_string( length )
		string = ""
		
		while( length > 0 )
			byte1 = read_byte
			length -= 1
			string << byte1.chr
		end
		
		string
	end
	
	def read_bytes( length )
		bytes = Array.new
		
		while( length > 0 )
			byte = read_byte
			bytes.push byte
			length -= 1
		end
		
		bytes
	end
	
	def read_byte
		@index += 1
		@bytes[@index - 1]
	end
	
	def read_var_integer
		num = read_byte
		return 0 if num.nil?
		num = num & 0xFF
		return num if( num < 128 )
		
		val = (num & 0x7F) << 7
		num = next_byte
		return (val | num) if( num < 128 )
		
		val = (val | num & 0x7F) << 7
		num = next_byte
		return (val | num) if( num < 128 )
		
		val = (val | num & 0x7F) << 8
		num = next_byte
		val = val | num
		
		if val >= 0x10000000
			val - 0x20000000
		else
			val
		end
	end
	
	private
	def next_byte
		num = read_byte()
		if num.nil?
			return 0
		else
			num & 0xFF
		end
	end
end

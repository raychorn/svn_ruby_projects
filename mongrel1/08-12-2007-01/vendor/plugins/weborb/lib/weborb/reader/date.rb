require 'weborb/io/binary_reader'
require 'weborb/formats/parse_context'
require 'date/format'
require 'weborb/util'

class DateType

  def initialize(date_time, time_offset, time)
    @date_time = date_time
    @time_offset = time_offset
    @time = time
  end
  
  def default_adapt
    @time
  end 

  def get_date_time
    @date_time
  end
  
  def get_time_offset
    @time_offset
  end

  def get_time
    @time
  end
end

class DateReader
  def read( reader, parse_context )
    epoch = Time.utc(1970,"jan",1)
    local_timezone_offset = Time.zone_offset epoch.zone
    epoch = epoch + local_timezone_offset
    date_time = reader.read_double
    reader.read_unsigned_short
    
    time_in_seconds = date_time/1000
    sent = epoch + time_in_seconds
    addtl_milli = date_time % 1000
    sent = Time.at( sent.to_i, addtl_milli * 1000 )
    sent
  end
end

class V3DateReader
  def read( reader, parse_context )
    ref_id = reader.read_var_integer
    return parse_context.get_reference( ref_id >> 1 ) if( (ref_id & 0x1) == 0 )
    date_time = reader.read_double
    
    epoch = Time.utc(1970,"jan",1)
    local_timezone_offset = Time.zone_offset epoch.zone
    epoch = epoch + local_timezone_offset
    
    time_in_seconds = date_time/1000
    sent = epoch + time_in_seconds
    addtl_milli = date_time % 1000
    sent = Time.at( sent.to_i, addtl_milli * 1000 )
    parse_context.add_reference(sent)
    sent
  end
end

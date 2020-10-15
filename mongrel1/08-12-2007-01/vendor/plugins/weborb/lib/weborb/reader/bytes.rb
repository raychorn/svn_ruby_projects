class V3ByteArrayReader
  def read( reader, parse_context )
    ref_id = reader.read_var_integer
    return parse_context.get_reference( ref_id >> 1 ) if( (ref_id & 0x1) == 0 )
    bytes = reader.read_bytes( ref_id >> 1 )
    parse_context.add_reference( bytes )
    bytes
  end
end
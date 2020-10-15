require 'weborb/config/weborb_config'

class Mapping
  
  def Mapping.init_service_mappings
    @@service_mappings = Hash.new
  end

  def Mapping.get_client_class( server_class )
    server_mappings = WebORBConfig.get_server_mappings
    
    if server_mappings[server_class].nil?
      server_class
    else
      server_mappings[server_class]
    end
  end
  
  def Mapping.get_server_class_info( client_class )
    client_mappings = WebORBConfig.get_client_mappings
    client_mappings[client_class]
  end
  
  def Mapping.add_service_mapping( destination_id, source )
    @@service_mappings[destination_id] = source
  end

  def Mapping.get_service_mapping( destination_id )
    if @@service_mappings[destination_id].nil?
      destination_id
    else
      @@service_mappings[destination_id]
    end
  end
  
end
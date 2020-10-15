require 'weborb/mapping'
require 'rexml/document'

class FlexRemotingServiceConfig

  def FlexRemotingServiceConfig.configure
    config_path = "#{RAILS_ROOT}/config/WEB-INF/flex/remoting-config.xml"
    file = File.new(config_path)
    config_document = REXML::Document.new(file)
    service_element = config_document.root
    
    service_element.elements.each( 'destination' ) do | destination_element |
      destination_id = destination_element.attribute('id').value
      properties_element = destination_element.elements['properties']
      source = properties_element.elements['source'].get_text.to_s
      
      #TODO: finish handling SCOPE
      #scope_element = properties_element.elements['scope']
	  #scope = scope_element.get_text.to_s unless scope_element.nil?
	  Mapping.add_service_mapping( destination_id, source )
    end
  end
end
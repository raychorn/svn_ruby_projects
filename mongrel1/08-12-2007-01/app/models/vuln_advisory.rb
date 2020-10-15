class VulnAdvisory < ActiveRecord::Base
  belongs_to :vuln
  belongs_to :vuln_advisory_publisher
  
  validates_presence_of :vuln, :vuln_advisory_publisher, :advisory_id
  
  alias_method :publisher, :vuln_advisory_publisher
end

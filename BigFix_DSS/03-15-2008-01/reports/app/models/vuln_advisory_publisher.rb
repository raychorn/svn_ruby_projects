class VulnAdvisoryPublisher < ActiveRecord::Base
  has_many :vuln_advisories
  
  validates_presence_of :name
  
  def self.CVE
    @@cve_publisher ||= find_by_name 'CVE'
  end
end

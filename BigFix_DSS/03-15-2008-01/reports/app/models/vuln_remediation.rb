class VulnRemediation < ActiveRecord::Base
  has_and_belongs_to_many :vulns
  belongs_to :remediation_type
  belongs_to :app_upgrade  # Optional, only if remediation_type == "App Upgrade"
  
  validates_presence_of :vuln, :remedation_type, :description
  
  def remediation_base_cost
    1
  end
  
  def remediation_base_value
    vuln.cvss_base_score
  end
  
  def remediation_cost(conditions)
    vuln.affected_computers_count(conditions) * remediation_base_cost
  end
  
  def remediation_value(conditions)
    vuln.affected_computers_count(conditions) * remediation_base_value
  end
end

class Vuln < ActiveRecord::Base
  has_and_belongs_to_many :apps
  has_many :vuln_remediations
  has_many :vuln_advisories
  belongs_to :vuln_severity
  
  validates_presence_of :name
  
  alias_method :remediations, :vuln_remediations
  alias_method :advisories, :vuln_advisories
  alias_method :severity, :vuln_severity
  
  def severity_name
    if vuln_severity.nil?
      ''
    else
      vuln_severity.name
    end
  end
  
  def cve
    cve_publisher = VulnAdvisoryPublisher.CVE.id
    
    advisory = advisories.to_a.find { |a| a.vuln_advisory_publisher_id == cve_publisher }
    
    if advisory.nil?
      nil
    else
      advisory.advisory_id
    end
  end
  
  def affected_computers_count(groups=nil)
    sql = "SELECT count(distinct computer_vulns.computer_id) FROM computer_vulns"
    conditions = "computer_vulns.vuln_id = #{id} AND computer_vulns.valid_from <= now() AND (computer_vulns.valid_to IS NULL OR computer_vulns.valid_to > now())"
    if groups and !groups.empty?
      sql += " INNER JOIN computer_groups_computers ON (computer_groups_computers.computer_id = computer_vulns.computer_id AND computer_groups_computers.valid_from <= now() AND (computer_groups_computers.valid_to IS NULL OR computer_groups_computers.valid_to > now())) AND computer_groups_computers.computer_group_id IN (#{groups.map(&:to_s).join(',')})"
    end
    
    connection.select_value("#{sql} WHERE #{conditions}").to_i
  end
  
  def self.vuln_distribution(groups=nil)
    sql = "SELECT vuln_id, count(distinct computer_vulns.computer_id) AS count FROM computer_vulns"
    conditions = "computer_vulns.valid_from <= now() AND (computer_vulns.valid_to IS NULL OR computer_vulns.valid_to > now())"
    if groups and !groups.empty?
      sql += " INNER JOIN computer_groups_computers ON (computer_groups_computers.computer_id = computer_vulns.computer_id AND computer_groups_computers.valid_from <= now() AND (computer_groups_computers.valid_to IS NULL OR computer_groups_computers.valid_to > now())) AND computer_groups_computers.computer_group_id IN (#{groups.map(&:to_s).join(',')})"
    end
    
    connection.select_all("#{sql} WHERE #{conditions} GROUP BY vuln_id").inject({}) { |h, row| (h[row['vuln_id'].to_i] = row['count'].to_i);  h }
  end
end

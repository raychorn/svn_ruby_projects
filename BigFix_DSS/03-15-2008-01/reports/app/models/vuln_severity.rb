class VulnSeverity < ActiveRecord::Base
  has_many :vulns
  
  validates_presence_of :name
end

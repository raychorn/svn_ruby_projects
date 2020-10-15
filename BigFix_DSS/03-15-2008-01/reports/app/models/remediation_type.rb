class RemediationType < ActiveRecord::Base
  has_many :vuln_remediations
  
  validates_presence_of :name
end

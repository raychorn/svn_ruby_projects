class ComputerVuln < ActiveRecord::Base
  belongs_to :vuln
  belongs_to :computer
end

class ComputerContact < ActiveRecord::Base
  belongs_to :computer
  belongs_to :contact
  belongs_to :computer_relationship_type
end

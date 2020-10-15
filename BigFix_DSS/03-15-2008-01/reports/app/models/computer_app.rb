class ComputerApp < ActiveRecord::Base
  belongs_to :computer
  belongs_to :app
end

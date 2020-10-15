class Note < ActiveRecord::Base
  attr_accessible :content, :created_at, :updated_at
  
  belongs_to :user
end

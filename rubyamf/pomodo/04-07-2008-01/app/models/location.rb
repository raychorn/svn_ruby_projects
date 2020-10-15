class Location < ActiveRecord::Base
  attr_accessible :name, :notes, :created_at, :updated_at
  
  belongs_to :user
  has_many :tasks, :dependent => :nullify
end

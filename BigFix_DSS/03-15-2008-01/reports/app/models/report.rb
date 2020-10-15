class Report < ActiveRecord::Base
    #belongs_to :user
  has_many :report_schedules
  has_many :report_builders
  #acts_as_list :scope => :user
	validates_uniqueness_of :name, :scope => :user_id
end

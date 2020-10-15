class Report < ActiveRecord::Base
    #belongs_to :user
  has_many :report_schedules
	#acts_as_list :scope => :user
	validates_uniqueness_of :name, :scope => :user_id
	serialize :data
end

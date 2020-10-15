class Dashboard < ActiveRecord::Base
	belongs_to :user
  belongs_to :dashboard_layout
	has_many :dashboard_dashboard_widgets, :dependent => :destroy, :order => 'position'
	has_many :dashboard_widgets, :through => :dashboard_dashboard_widgets, :order => 'dashboard_dashboard_widgets.position'
	acts_as_list :scope => :user
	
	validates_uniqueness_of :name, :scope => :user_id
end

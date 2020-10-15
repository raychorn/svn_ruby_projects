class DashboardDashboardWidget < ActiveRecord::Base
	belongs_to :dashboard
	belongs_to :dashboard_widget
end

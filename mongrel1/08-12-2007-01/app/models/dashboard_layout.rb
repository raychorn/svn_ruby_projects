class DashboardLayout < ActiveRecord::Base
	has_many :dashboards
  serialize :layout_data
end

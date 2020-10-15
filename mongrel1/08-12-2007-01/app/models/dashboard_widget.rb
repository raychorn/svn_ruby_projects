require 'models/report_subject'
require 'models/report_metric'
require 'helpers/flex_only_classes'
require 'computer_group'  # XXX: This should, but doesn't, get auto-loaded during YAML parsing of the visualization_type_options.

class DashboardWidget < ActiveRecord::Base
	belongs_to :user
	has_many :dashboard_dashboard_widgets, :dependent => :destroy
	belongs_to :visualization_type
	serialize :visualization_type_options
end

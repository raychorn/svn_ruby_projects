class ReportBuilder < ActiveRecord::Base
	attr_accessor :scaleImage
    belongs_to :report
end

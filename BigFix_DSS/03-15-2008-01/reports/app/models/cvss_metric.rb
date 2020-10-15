class CVSSMetric < ActiveRecord::Base
  belongs_to :CVSSMetricGroups
  has_many :CVSSMetricValues
end
class CVSSMetricValue < ActiveRecord::Base
  belongs_to :CVSSMetric
  has_and_belongs_to_many :Vulns
end
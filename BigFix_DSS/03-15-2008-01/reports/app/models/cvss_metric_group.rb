class CVSSMetricGroup < ActiveRecord::Base
  has_many :CVSSMetrics
end
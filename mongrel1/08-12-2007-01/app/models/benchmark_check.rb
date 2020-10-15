class BenchmarkCheck < ActiveRecord::Base
  belongs_to :benchmark_version
  belongs_to :benchmark_check_group
  
  validates_presence_of :name, :benchmark_version
end

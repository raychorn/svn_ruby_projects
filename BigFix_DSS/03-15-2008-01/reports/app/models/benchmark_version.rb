class BenchmarkVersion < ActiveRecord::Base
  belongs_to :platform_benchmark
  has_many :benchmark_checks
  
  validates_presence_of :platform_benchmark, :version
end

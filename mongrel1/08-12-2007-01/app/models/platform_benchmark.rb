class PlatformBenchmark < ActiveRecord::Base
  set_table_name :benchmarks
  has_many :benchmark_versions
  has_and_belongs_to_many :platforms, :join_table => 'benchmark_platforms'
end

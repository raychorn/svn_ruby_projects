class ComputerBenchmark < ActiveRecord::Base
  belongs_to :computer
  belongs_to :benchmark
end

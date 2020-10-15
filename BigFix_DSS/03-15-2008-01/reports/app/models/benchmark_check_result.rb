class BenchmarkCheckResult < ActiveRecord::Base
  belongs_to :computer
  belongs_to :benchmark_check
  
  validates_presence_of :computer, :benchmark_check, :pass, :valid_from, :valid_to
end

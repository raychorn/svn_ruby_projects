class BenchmarkCheckGroup < ActiveRecord::Base
  acts_as_tree
  
  belongs_to :benchmark_version
  has_many :benchmark_checks
  
  validates_presence_of :name
end

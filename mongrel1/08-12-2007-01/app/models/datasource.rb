class Datasource < ActiveRecord::Base
  belongs_to :datasource_type
  serialize :connection_params
  has_and_belongs_to_many :computers
end

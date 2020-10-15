class DatasourceComputerGroup < ActiveRecord::Base
  belongs_to :datasource
  validates_presence_of :datasource_computer_group_id, :name, :datasource

  # Not really editable, but loadable using the Editor service.
  editable
  
  def is_viewable_by?(user)
    true
  end
  
  def is_editable_by?(user)
    false
  end
end

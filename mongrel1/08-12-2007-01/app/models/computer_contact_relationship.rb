class ComputerContactRelationship < ActiveRecord::Base
  belongs_to :user
  belongs_to :computer_relationship_type
  
  validates_presence_of :user, :computer_relationship_type

  def is_viewable_by?(user)
    true
  end
  
  def is_editable_by?(user)
    user.admin?
  end
  
  def is_deletable_by?(user)
    user.admin?
  end
end

class Project < ActiveRecord::Base
  attr_accessible :name, :notes, :completed, :created_at,
    :updated_at
  
  belongs_to :user
  has_many :tasks, :dependent => :delete_all
  has_one :next_action,
          :class_name => "Task",
          :conditions => "next_action='1'"
          
  def save_with_gtd_rules!
    if self.completed
      transaction do
        self.tasks.update_all(:completed => true)
        if self.next_action
          self.next_action.next_action = false
          self.next_action.save!
        end
        self.save!
      end
    else
      self.save!
    end
  end
end

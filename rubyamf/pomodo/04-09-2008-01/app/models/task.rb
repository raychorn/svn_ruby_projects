class Task < ActiveRecord::Base
  attr_accessible :name, :notes, :next_action, :completed,
    :project_id, :location_id, :created_at, :updated_at

  belongs_to :user
  belongs_to :location
  belongs_to :project

  def before_save
    self.project_id = nil if self.project_id == 0
    self.location_id = nil if self.location_id == 0
  end
  
  def save_with_gtd_rules!
    if self.completed
      # A completed task cannot be the next_action, so one of
      # these flags has to win. Arbitrarily, we decide that the
      # completed flag takes precedence over the next_action
      # flag.
      self.next_action = false
    end
    if self.project
      prev_next_action = self.project.next_action
      next_action_changing =
        prev_next_action && (self != prev_next_action)
      project_completed_changing =
        !self.completed && self.project.completed
      if next_action_changing || project_completed_changing
        # If either of these are also changing, we need an
        # explicit transaction.
        transaction do
          if next_action_changing
            prev_next_action.next_action = false
            prev_next_action.save!
          end
          if project_completed_changing
            self.project.completed = false
            self.project.save!
          end
          self.save!
        end
      else
        self.save! # We just need to save the task.
      end
    else
      # No project, so if we're not completed we force the
      # next_action to true.
      if !self.completed
        self.next_action = true
      end
      self.save!
    end
  end
end

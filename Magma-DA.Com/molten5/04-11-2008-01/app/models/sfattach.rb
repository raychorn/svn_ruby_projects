class Sfattach < ActiveRecord::Base
  sync :with => Attachment
  set_primary_key "sf_id"
  #------------------
  # ASSOCIATIONS
  #------------------
  belongs_to :last_modified_by, :class_name => "Sfuser", :foreign_key => "last_modified_by_id"
  # belongs_to :solution, :class_name => "Sfsolution", :foreign_key => "parent_id"
  
  #################
  ### Callbacks ###
  #################
  after_save :set_case_last_updated_time
  
  def set_case_last_updated_time
    parent.set_update_time!(self.last_modified_date) if parent.is_a?(Sfcase)
  end
  
  #------------------
  # INSTANCE METHODS
  #------------------
  
  # Returns the file extension based on the +name+.
  def extension
    name.gsub(/\w+\./,'')
  end
  
  # Parent can be a solution or a case
  def parent
    if record = Sfsolution.find_by_sf_id(parent_id)
      record
    else
      record = Sfcase.find_by_sf_id(parent_id)
    end
  end
end

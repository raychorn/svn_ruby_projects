class Lead < ActiveRecord::Base
  #################
  ### Behaviors ###
  #################
  establish_connection :salesforce
  set_primary_key "id"
  set_table_name 'lead'
  
  ###################
  ### Assocations ###
  ###################
  belongs_to :owner, :class_name => "User", :foreign_key => "owner_id"
  # combines the user's first and last name
  
  #################
  ### Constants ###
  #################
  
  MOLTEN_REQUEST_RECORD_TYPE = '0123000000000gd'
  
  ###################
  ### Validations ###
  ###################
  validates_presence_of :salutation, :first_name, :last_name, :company, :email,
                        :phone, :country, :title, :street, :city, :state, :postal_code,
                        :business_unit__c, :description,
                        :if => Proc.new { |c| c.validate_attributes == true }
  validate_on_create :validates_email_uniqueness
  
  ##########################
  ### Virtual Attributes ###
  ##########################
  
  ########################
  ### Instance Methods ###
  ########################
  
  def validate_attributes=(new_attribute)
    @validate_attributes = new_attribute
  end
  
  def validate_attributes
    @validate_attributes
  end
  
  def name
    "#{first_name} #{last_name}".strip
  end
  
  private
  
  # Can't have a contact account and must not have an exisiting
  # lead with the MOLTEN_REQUEST_RECORD_TYPE record type.
  def validates_email_uniqueness
    if validate_attributes == true
      if email and (Contact.find_by_email(email) or Lead.find(:first, :conditions => ["email = ? and record_type_id = ?",email,MOLTEN_REQUEST_RECORD_TYPE]))
        errors.add('email', "A contact already exists with this email address.")
      end
    end
  end
end

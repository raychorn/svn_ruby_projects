require 'vpim'
require 'editor_support'

class Contact < ActiveRecord::Base
  belongs_to :user
  has_many :computer_relationships, :class_name => 'ComputerContact',
           :table_name => 'computers_contacts'
  has_many :computer_contact_relationships
  
  validates_presence_of :vcard

  editable
  
  def editor_attributes
    attrs = %w(id user_id name email telephone)
    attrs.inject({}) { |h, n| h[n] = self.send(n.to_sym);h }
  end
  
  def before_validation
    self.vcard = vCard.to_s
  end
  
  def vCard
    @vcard ||= (vcard.blank? ? Vpim::Vcard.create : Vpim::Vcard.decode(vcard).first)
  end
  
  def vCard=(card)
    @vcard=card
    @vcard_dirty = true
  end
  
  def name
    vCard.name.fullname
  end
  
  def telephone
    vCard.telephone.to_s
  end
  
  def email
    vCard.email.to_s
  end
  
  def is_viewable_by?(user)
    true
  end
  
  def is_editable_by?(user)
    user.admin?
  end
end

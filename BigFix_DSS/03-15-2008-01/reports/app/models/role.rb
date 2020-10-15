require 'editor_support'

class Role < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_and_belongs_to_many :computer_groups
  
  validates_presence_of :name
  
  editable

  def self.user_find_options(user, options)
    return options if user.nil? || user.admin?

    returning options do
      options[:select] ||= 'roles.*'
      options[:joins] ||= ''
      options[:joins] += " INNER JOIN roles_users ON (roles.id = roles_users.role_id AND roles_users.user_id = #{user.id})"
    end
  end

  def repair_permissions(groups=nil)
    groups ||= ComputerGroup.find_all_as_indexed_tree

    # For each group we have permission to, we should have permission to each
    # of its included groups.
    
    correct_group_ids = Set.new
        
    computer_group_ids.each do |cgid|
      if groups.has_key?(cgid)
        correct_group_ids << cgid
        correct_group_ids.merge(groups[cgid].descendants.map(&:id))
      end
    end
    
    unless Set.new(computer_group_ids) == correct_group_ids
      self.computer_group_ids = correct_group_ids.to_a
    end
    
    nil
  end
  
  def self.repair_permissions(role_ids=nil)
    return if !role_ids.nil? && role_ids.empty?
    
    groups = ComputerGroup.find_all_as_indexed_tree
    find(role_ids || :all, :include => :computer_groups).each do |role|
      role.repair_permissions(groups)
    end
    
    nil
  end
  
  def is_viewable_by?(user)
    user.admin? || user.roles.include?(self)
  end
  
  def is_editable_by?(user)
    user.admin?
  end

	def property_is_viewable_by?(property_name, user)
	  super(property_name, user) || property_name == 'user_ids' || property_name == 'computer_group_ids'
  end
  
  def property_is_editable_by?(property_name, user)
    super(property_name, user) || ((property_name == 'user_ids' || property_name == 'computer_group_ids') && user.admin?)
  end
end

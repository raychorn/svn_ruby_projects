class Editor < ServiceController
  def list(args)
    raise "Not logged in" unless logged_in?
    
    klass = self.class.getObjectClass(args['class'])
    find_args = { :user => current_user }
    if args['sortBy']
      sort_by = args['sortBy']
      sort_direction = args['sortDirection'] == 'ASC' ? 'ASC' : 'DESC'
      
      if klass.columns.map(&:name).include?(sort_by)
        find_args[:order] = "#{sort_by} #{sort_direction}"
      end
    end
    
    find_args[:order] ||= "id ASC"
    
    if offset = args['offset']
      find_args[:offset] = [0, offset.to_i].max
    end
      
    if count = args['count']
      find_args[:limit] = [0, count.to_i].max
    end
    
    klass.find(:all, find_args)
  end
  
  def get(args)
    klass = self.class.getObjectClass(args['class'])
    objid = args['id'].to_i
    
    obj = begin
      klass.find(objid)
    rescue
      nil
    end
    
    raise "Permission denied" unless obj && obj.is_viewable_by?(current_user)
    
    obj
  end
  
  def get_property(args)
    klass = self.class.getObjectClass(args['class'])
    objid = args['id'].to_i
    property_name = args['property'].to_s
    
    obj = begin
      klass.find(objid)
    rescue
      raise "Object not found"
    end
    
    raise "Permission denied" unless obj && obj.is_viewable_by?(current_user)
    raise "Unknown property" unless obj.property_is_viewable_by?(property_name, current_user)
    
    obj.send(property_name)
  end
  
  def update(updated_obj, attrs={})
    klass = self.class.getObjectClass(updated_obj.class)    
    objid = updated_obj.id
    
    obj = begin
      klass.find(objid)
    rescue
      nil
    end
    
    raise "Permission denied" unless obj && obj.is_editable_by?(current_user)

    obj.editor_update_attributes(updated_obj.attributes)

    attrs.each do |property_name, value|
      if obj.property_is_editable_by?(property_name, current_user)
        obj.send(property_name + '=', value)
      end
    end unless attrs.nil?
    
    obj.save!
    obj
  end
  
  def create(arg)
    if arg.is_a?(Hash)
      klass = self.class.getObjectClass(arg['class'])
      obj = klass.editor_create(arg['attributes'])
    else
      klass = self.class.getObjectClass(arg.class)
      obj = klass.editor_create(arg.attributes)
    end

    raise "Permission denied" unless obj.is_createable_by?(current_user)

    obj.save!
    obj
  end
  
  def delete(args)
    klass = self.class.getObjectClass(args['class'])
    objid = args['id'].to_i
    obj = begin
      klass.find(objid)
    rescue
      nil
    end
    
    raise "Permission denied" unless obj && obj.is_deleteable_by?(current_user)

    obj.destroy
    nil
  end
  
  def deleteMany(args)
    klass = args['class']
    begin
      args['ids'].each { |id| delete('class' => klass, 'id' => id) }
    rescue
      # Errors are suppressed as a cheap way of dealing with computer groups,
      # where a request may arrive to delete both the parent and a child.  If
      # the parent is deleted first, the request to delete the child will
      # result in an error, because the parent's deletion will have already
      # resulted in the child's deletion.
      nil
    end
    
    nil
  end
  
  protected
  def self.getObjectClass(classname)
    classname = classname.name if classname.is_a?(Class)
    raise 'Class name must be a string' unless classname.is_a?(String)
    klass = begin
      Object.const_get(classname)
    rescue NameError
      nil
    end
    
    if supported_classes.include? klass
      klass
    else
      raise "Invalid class '#{classname}'"
    end
  end
  
  def self.supported_classes
    [User, Role, Contact, ComputerGroup, DatasourceComputerGroup]
  end
end
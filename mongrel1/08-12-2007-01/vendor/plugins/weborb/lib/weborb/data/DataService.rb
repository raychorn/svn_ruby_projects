class DataService
  def create( model_name, model_info )
    model_class = Object.const_get model_name
    model = model_class.new(model_info)
    save_success = model.save
    model
  end
  
  def update( model_name, model_info )
    model_class = Object.const_get model_name
    update_method = model_class.method :update
    model = update_method.call(model_info['id'], model_info)
    model
  end
  
  def remove( model_name, model_id )
    model_class = Object.const_get model_name
    delete_method = model_class.method :delete
    delete_success = delete_method.call(model_id)
    delete_success
  end
  
  def list( model_name )
    model_class = Object.const_get model_name
    find_method = model_class.method :find
    find_method.call(:all)
  end
end
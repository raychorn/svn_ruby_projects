class AppRelationship < ActiveRecord::Base
  belongs_to :app
  belongs_to :related_app, :class_name => 'App', :foreign_key => 'related_app_id'
  belongs_to :app_relationship_type
  
  validates_presence_of :app, :related_app, :app_relationship_type
  
  def relationship_name
    app_relationship_type.name
  end
  
  def humanize
    "#{app.name} #{relationship_name} #{related_app.name}"
  end
end

class AppRelationshipType < ActiveRecord::Base
  has_many :app_relationships
  validates_presence_of :name
  
  def self.lookup_type(type)
    @@types ||= self.find(:all).index_by { |obj| obj.name.gsub(' ', '_').to_sym }
    
    @@types[type].id
  end
end

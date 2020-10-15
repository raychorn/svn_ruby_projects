require 'app_relationship'
require 'editor_support'

class App < ActiveRecord::Base
  acts_as_graph :class_name => 'AppRelationship',
                :from_key => 'app_id',
                :to_key => 'related_app_id'
  
  has_and_belongs_to_many :vulns, :include => :vuln_advisories
  validates_presence_of :name
  editable
  
  def relationships
    outgoing_edges + incoming_edges
  end
  
  def versions
    @versions ||=
      # XXX: Incomplete; doesn't account for multiple levels of versions.
      self.class.find_by_sql ['SELECT apps.* FROM apps ' \
                              'INNER JOIN app_relationships ON' \
                              ' app_relationships.related_app_id = apps.id ' \
                              'WHERE app_relationships.app_id = ? AND' \
                              ' app_relationships.app_relationship_type_id = ?',
                              id, AppRelationshipType.lookup_type(:is_instantiated_by)]
  end
  
  def has_relationship_out?(type)
    type_id = AppRelationshipType.lookup_type(type)
    not outgoing_edges.find_by_app_relationship_type_id(type_id).nil?
  end
  
  def has_relationship_in?(type)
    type_id = AppRelationshipType.lookup_type(type)
    not incoming_edges.find_by_app_relationship_type_id(type_id).nil?
  end
  
  def self.find_all_applications
    find_by_sql ['SELECT DISTINCT apps.* FROM apps INNER JOIN app_relationships ON' \
                 ' (app_relationships.related_app_id = apps.id) WHERE app_relationship_type_id IN (?, ?)',
                 AppRelationshipType.lookup_type(:bundles),
                 AppRelationshipType.lookup_type(:publishes)]
  end
  
  def self.find_by_vendor_and_name(vendor_name, app_name)
    vendor = self.find_vendor(vendor_name)
    
    return nil if vendor.nil?
    
    vendor.find_published_app(app_name)
  end
  
  def self.find_vendor(vendor_name)
    publish_relationship_type = AppRelationshipType.lookup_type(:publishes)
    
    self.find_by_sql(["SELECT apps.* FROM apps INNER JOIN app_relationships ON apps.id = app_relationships.app_id WHERE name = ? AND app_relationships.app_relationship_type_id = ? LIMIT 1",
                     vendor_name, AppRelationshipType.lookup_type(:publishes)])[0]
  end
  
  def find_published_app(app_name)
    publish_relationship_type = AppRelationshipType.lookup_type(:publishes)
    
    self.class.find_by_sql(["SELECT apps.* FROM apps INNER JOIN app_relationships ON apps.id = app_relationships.related_app_id WHERE apps.name = ? AND app_relationships.app_id = ? AND app_relationships.app_relationship_type_id = ? LIMIT 1",
                           app_name, id, AppRelationshipType.lookup_type(:publishes)])[0]
  end
  
  def self.create_by_vendor_and_name(vendor_name, app_name)
    vendor = self.find_vendor(vendor_name)

    transaction do
      if vendor.nil?
        vendor = App.new(:name => vendor_name)
        vendor.save!
      elsif (app = vendor.find_published_app(app_name))
        return app
      end

      vendor.add_published_app(app_name)
    end
  end
  
  def add_published_app(app_name)
    create_child_with_relationship(app_name,
                                   AppRelationshipType.lookup_type(:publishes))
  end
  
  def add_version(version_name)
    if (v = find_version(version_name))
      return v
    end
    
    @versions = nil # Clear cache
    
    create_child_with_relationship(name + ' ' + version_name,
                                   AppRelationshipType.lookup_type(:is_instantiated_by))
  end
  
  def create_child_with_relationship(child_name, rel_type)
    transaction do
      new_app = App.new(:name => child_name)
      new_app.save!
    
      rel = AppRelationship.new(:app_relationship_type_id => rel_type,
                                :app => self,
                                :related_app => new_app)
      rel.save!
      
      new_app
    end
  end
  
  def find_version(version_name)
    return self if version_name.empty?
    
    app_version_name = "#{name} #{version_name}"
    
    inst_relationship_type = AppRelationshipType.lookup_type(:is_instantiated_by)

    candidates = versions

    iterations = 0
    while not candidates.empty?
      if iterations > 100:
        raise RuntimeError, "Too many iterations looking for version #{version_name} of #{name} (cycle in the graph?)"
      end
      iterations += 1
      
      v = candidates.find { |ver| ver.name.casecmp(version_name) == 0 || ver.name.casecmp(app_version_name) == 0 }
      return v unless v.nil?
            
      candidates = candidates.map(&:versions).flatten
    end
  end
end

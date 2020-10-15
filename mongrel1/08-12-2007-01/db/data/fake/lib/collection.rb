require 'lib/core_extensions'
require 'yaml'

class CollectionItem < Hash
  def initialize(key, attributes)
    super()
    @key = key
    replace(attributes)
  end
  
  def merge!(h)
    h.each do |k, v|
      self[k] = \
      if !has_key?(k)
        v
      elsif self[k].class == v.class
        case v
        when Array
          self[k] + v
        when Hash
          v.merge self[k]
        else
          self[k]
        end
      else
        self[k]
      end
    end
    self
  end
  
  def merge(h)
    n = clone()
    n.merge!(h)
  end
  
  def to_h
    returning h = {} do
      h.replace(self)
    end
  end
end

class Collection
  def initialize(pathname, item_class=CollectionItem)
    @root_path = pathname
    @item_class = item_class
  end
  
  def entities
    @entities ||= load_all_entities
  end
  
  def [](name)
    entities[name]
  end
  
  private
  def each_file(start=@root_path, &block)
    Dir.new(start).each do |path|
      if path[0..0] != '.'
        full_path = start + File::SEPARATOR + path
        if File.stat(full_path).directory?
          each_file(full_path, &block)
        else
          yield File.new(full_path, 'r')
        end
      end
    end
  end

  def load_all_entities
    returning entities = {} do
      each_file do |f|
        entities.merge!(YAML::load(f).map_values { |k, v| @item_class.new(k, v) })
      end
    end
  end
end

require 'yaml'
require 'set'

require 'lib/core_extensions'
require 'lib/collection'

class CorpusEntity
  attr_reader :key
  attr_reader :title
  attr_reader :abbrev
  attr_reader :type
  attr_reader :children
  attr_reader :views
  attr_reader :attrs
  attr_reader :parents
  
  def initialize(key, definition)
    @key = key
    @title = definition['title']
    @abbrev = definition['abbrev']
    @type = definition['type'] || 'group'
    @children = definition['subgroups'] || []
    @views = definition['views'] || []
    @parents = []
    @attrs = definition
  end
  
  def descendants
    returning Array.new(@children) do |ents|
      @children.each do |ent|
        ents.concat ent.descendants
      end
    end
  end
  
  def ancestors
    returning Array.new(@parents) do |ents|
      @parents.each do |ent|
        ents.concat ent.ancestors
      end
    end
  end
  
  def each_ancestor(&block)
    @parents.each &block
    @parents.each { |parent| parent.each_ancestor(&block) }
  end
  
  def to_s
    title.nil? ? key : title
  end
  
  def self.common_ancestors_of(entities)
    s = Set.new entities[0].ancestors
    
    s.find_all do |a|
      entities[1..-1].each do |e|
        e.each_ancestor { |x| break true if s.include?(x) }
      end
    end

    #entities[1..-1].inject(Set.new(entities[0].ancestors)) do |common, e|
    #  common & e.ancestors
    #end
  end

  def self.all_ancestors_of(entities)
    parents = entities.inject(Set.new) { |all, e| all.merge(e.parents) }
    parents.inject(Set.new(parents)) { |all, e| all.merge(e.ancestors) }
  end

  def self.build_tree(entities)
    entities.each { |k, e| e.lookup_children_from(entities) }
  end
  
  def lookup_children_from(entities)
    @children.map! { |k| entities[k] }
    @children.compact!
    @children.uniq!
    @children.freeze
    @children.each { |child| child.add_parent(self) }
  end
  
  def add_parent(parent)
    @parents << parent
  end
end

class GroupCorpus < Collection
  private
  
  def load_all_entities
    returning super do |entities|
      self.class.resolve_includes(entities)
    
      entities.replace entities.map_values { |k, v| CorpusEntity.new(k, v) }
      CorpusEntity.build_tree(entities)
    end
  end
  
  def self.resolve_includes(entities)
    entities.each do |name, edef|
      next unless edef.is_a?(Hash)
      
      includes = (edef['includes'] || []) + (edef['views'] || [])
      
      edef['subgroups'] ||= []

      includes.each do |sg_name|
        edef['subgroups'].concat(entities[sg_name]['subgroups'] || []) if entities.has_key?(sg_name)
      end
    end
  end
end

class PickerConfigError < Exception
end

class GroupTreeConfig < Hash
  def initialize(filename, defaults={})  
    cfg = YAML::load(File.new(filename, 'r'))
    cfg = cfg[cfg.keys[0]]
      
    replace(defaults.merge(cfg))
  end
end

class GroupPicker
  def initialize(corpus, config)
    @corpus = corpus
    @config = config
    @obj_type = @config['pick']
  end
  
  def make_computer_groups(entities, computer_counts = {})
    config_views = Set.new(@config['group_by'] || [])
    all_ancestors = CorpusEntity.all_ancestors_of(entities)
    common_ancestors = CorpusEntity.common_ancestors_of(entities)
    entities = Set.new entities

    views = Set.new(common_ancestors.map { |a| a.key })

    unless (v = views & config_views).empty?
      top = @corpus.entities[v.to_a[0]]
    else
      top = @corpus.entities[views.to_a[0]]
    end
    
    groups = { top.key => { 'title' => top.title, 'subgroups' => [] } }
    working_set = [top]
    
    until working_set.empty?
      new_working_set = []
      
      working_set.each do |e|
        views = Set.new e.views
        if (v = views & config_views).any?
          view = @corpus.entities[v.to_a[0]]
        elsif views.any?
          view = @corpus.entities[views.to_a[0]]
        else
          view = e
        end
        
        view.children.each do |child|
          next unless all_ancestors.include?(child) || entities.include?(child)
          groups[child.key] = { 'title' => child.title,
                                'subgroups' => [],
                                'computers' => computer_counts[child.key] || 0 }
          groups[e.key]['subgroups'] << child.key
          new_working_set << child
        end
      end
      
      working_set = new_working_set
    end

    group_tree = Hash[*groups[top.key]['subgroups'].map { |grp| [grp, groups[grp]] }.flatten]
    
    def lookup_subgroups(keys, groups)
      Hash[*keys.map do |key|
        groups[key]['subgroups'] = lookup_subgroups(groups[key]['subgroups'], groups)
        [key, groups[key]]
      end.flatten]
    end
    
    lookup_subgroups(groups[top.key]['subgroups'], groups)

    group_tree
  end
  
  def pick(count)
    proportion_set = normalize_proportion_set(@config['proportions'])
    proportion_tree = make_proportion_tree(proportion_set)

    counts = pick_groups('', proportion_tree[:children], count)
    
    pick_entities_of_type(@obj_type, counts)
  end

  def make_proportion_tree(proportion_set)
    tmp = proportion_set.map_values { |k, v| { :group_name => k } }
    proportion_set.each do |k, props|
      props.each do |pk, pv|
        tmp[pk] ||= { :group_name => pk }
        tmp[pk][:proportion] = pv
      end
      tmp[k][:children] = props.keys.map { |pk| tmp[pk] }
    end
    
    tmp['TOP']
  end
  
  private
  def pick_groups(groupname, subgroups, count)
    # This is totally ugly.
    counts = Hash[*subgroups.map { |grp| [grp, (grp[:proportion] * count).floor] }.flatten]

    new_counts = []

    other_group = counts.keys.find { |grp| grp[:group_name] == 'OTHER' }
    if other_group
      other_count = counts.delete other_group
      named_subgroups = subgroups.map { |sg| sg[:group_name] }
      other_subgroups = @corpus.entities[groupname].children.find_all { |child| !named_subgroups.member?(child.key) }
      new_counts.concat(get_random_subgroup_counts(other_subgroups, other_count))
    end

    counts.each do |grp, grp_count|
      if grp[:children] && !grp[:children].empty?
        new_counts.concat(pick_groups(grp[:group_name], grp[:children], grp_count))
      else
        new_counts << [grp[:group_name], grp_count]
      end
    end
    
    new_counts
  end
  
  def get_random_subgroup_counts(subgroups, total)
    return [] if subgroups.empty?
    
    count = total    
    counts = {}
    
    while count > 0
      group = subgroups.random
      n = (@config['min_cluster_size']..([@config['max_cluster_size'], count].min)).random()
      n = [n, count].min
      counts[group.key] = (counts[group.key] || 0) + n
      count -= n
    end

    counts.to_a
  end
  
  def pick_entities_of_type(type, counts)
    returning entities = {} do    
      counts.each do |group_name, count|
        next unless group = @corpus.entities[group_name]
        entities.merge! pick_entities_of_type_in_group(type, group, count)
      end
    end
  end
  
  def pick_entities_of_type_in_group(type, group, count)
    return { group.key => count } if group.type == type
    
    candidates = group.descendants.find_all { |e| e.type == type }
    entities = Hash.new { |h, k| h[k] = 0 }
    while count > 0 && !candidates.empty?
      n = (@config['min_cluster_size']..[@config['max_cluster_size'], count].min).random
      n = [n, count].min
      if @config['weight_by']
        group = pick_weighted_item(candidates.map { |c| [c, c.attrs[@config['weight_by']] || 1] })
      else
        group = candidates.random
      end
      entities[group.key] += n
      count -= n
    end
    
    entities.delete_if { |k, count| count < @config['min_cluster_size'] }
  end
  
  def normalize_proportion_set(pset)
    pset.map_values do |key, props|
      total = Float(props.values.sum)
      props.map_values { |k, v| v / total }
    end
  end
  
  def pick_weighted_item(items)
    weight_sum = items.inject(0) { |sum, x| sum + x[1] }
    rv = (0..weight_sum).random
    
    i = 0
    items.each do |item, weight|
      i += weight
      return item if i > rv
    end
  end
end


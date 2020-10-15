require 'lib/collection'
require 'lib/MultiFractal'
require 'set'

class RandomNameGenerator
  def initialize(args)
    @patterns = args[:patterns]
    @sources = args[:sources]
    @map = args[:map]
  end
  
  def generate_many(count)
    (0..count - 1).map { generate }
  end
  
  def generate
    pattern = @patterns.random
    words = pattern.map do |e|
      case e
      when String
        e
      else
        @sources[e].random
      end
    end
    
    s = words.join(' ')
    if @map
      @map.call(s)
    else
      s
    end
  end
end

class ComputerDef < CollectionItem
  def aggregate_cvss_score(defs, time=nil)
    vulnerabilities_at(time).uniq.map do |vuln_name|
      (defs[vuln_name] || {})['cvss_score'] || 0
    end.sum
  end

  def applications_at(time)
    objects_valid_at(self['applications'] || [], time)
  end
  
  def vulnerabilities_at(time)
    objects_valid_at(self['vulnerabilities'] || [], time)
  end
  
  def add_vulnerabilities(vulns)
    self['vulnerabilities'] = add_objects(self['vulnerabilities'] || [], vulns)
  end
  
  def set_vulnerabilities_at_time(vulns, time)
    self['vulnerabilities'] = set_objects_at_time(self['vulnerabilities'] || [], vulns, time)
  end
  
  def add_applications(apps)
    self['applications'] = add_objects(self['applications'] || [], apps)
  end
  
  def set_objects_at_time(original, objs, time)
    returning out = add_objects(original, objs) do
      object_records_at(out, time).each do |r|
        r[2] = time unless objs.find { |oo, ovf, ovt| r[0] == oo }
      end
    end
  end
  
  def add_objects(original, objs)
    returning original.dup do |out|
      objs.each do |obj, vf, vt|
        if prev = object_record_at(out, obj, vf)
          prev[2] = vt
        elsif !vt.nil? && post = object_record_at(out, obj, vt)
          post[1] = vf
        else        
          out << [obj, vf, vt]
        end
      end
    end
  end
  
  def object_record_at(objects, o, time)
    if time.nil?
      objects.find { |v, vf, vt| v == o && vt.nil? }
    else
      objects.find { |v, vf, vt| v == o && (vf <= time && (vt.nil? || vt > time)) }
    end
  end
  
  def object_records_at(objects, time)
    if time.nil?
      objects.find_all { |v, vf, vt| vt.nil? }
    else
      objects.find_all { |v, vf, vt| vf <= time && (vt.nil? || vt > time) }
    end
  end
  
  def objects_valid_at(objects, time)
    if time.nil?
      objects.inject([]) { |list, (v, vf, vt)| vt.nil? ? list << v : list }
    else
      objects.inject([]) { |list, (v, vf, vt)| vf <= time && (vt.nil? || vt > time) ? list << v : list }
    end
  end
  
  def to_h
    returning super do |h|
      h['applications'] = h['applications'].map { |a, vf, vt| { 'name' => a.name, 'valid_from' => vf.to_s, 'valid_to' => vt.to_s } }
      h['vulnerabilities'] = h['vulnerabilities'].map { |v, vf, vt| { 'cve' => v.cve, 'valid_from' => vf.to_s, 'valid_to' => vt.to_s } }
    end
  end
end

class ComputerDefs < Collection
  def initialize(*args)
    super(*args)
    @item_class = ComputerDef
  end
  
  private
  def load_all_entities
    returning entities = super do    
      self.class.resolve_includes(entities)
    end
  end
  
  def self.resolve_includes(entities)
    entities.each do |key, e|
      if e['include']
        includes = e.delete 'include'
        includes.each do |inc|
          next unless entities.has_key?(inc)
          e.merge!(entities[inc])
        end
      end
    end
  end
end

class ComputerGroupGenerator
  def initialize(choices)
    @choices = choices
  end
  
  def generate(count, base = {})
    choices = @choices.map_values { |k, v| v.dup }
    
    (0..count-1).map do
      base.merge(choices.map_values { |k, v| v.delete_at(rand(v.length)) })
    end
  end
end

class ComputerGenerator
  def initialize(collection, options = {})
    @collection = collection
    @apps_by_name = options[:apps_by_name] || App.find(:all).index_by(&:name)
  end

  def generate(base, profiles, config = {})
    returning ComputerDef.new(nil, base) do |comp|
      valid_from = config[:valid_from] || Time.now

      apply_profiles(comp, profiles)
      resolve_applications(comp, valid_from)
    
      if config[:target_cvss_score]
        comp['vulnerabilities'] = \
          pick_vulnerabilities_to_match_score(comp, config[:target_cvss_score], 0.5, valid_from)
      elsif config[:pick_random_vulns]
        comp['vulnerabilities'] = pick_vulnerabilities(comp, valid_from)
      end
    end
  end
  
  def apply_profiles(comp, profiles)
    profiles.each do |profile_name|
      puts "Profile #{profile_name} does not exist!" unless @collection[profile_name]
      comp.merge!(@collection[profile_name])
    end
  end
  
  def mutate(computer, start_date, end_date, mutation_count)
    mutation_interval = (end_date - start_date) / mutation_count
    
    score_line = MultiFractal::Generator.new([mutation_count, 50].max, 10.0 + 5.0 * rand, 10.0 + 5.0 * rand, 0, 55).line
    
    d = start_date + mutation_interval
    while d < end_date
      pos = (d - start_date) / (end_date - start_date)
      puts [d, pos, score_line[pos]].inspect
      vulns = pick_vulnerabilities_to_match_score(computer, score_line[pos], 0.5, d)
      computer.set_vulnerabilities_at_time(vulns, d)
      d += mutation_interval
    end
  end
  
  def resolve_applications(comp, valid_from)
    comp['applications'] = \
      comp['applications'].map { |app_name| @apps_by_name[app_name] }.compact
    comp['applications'] = comp['applications'].map { |a| [a, valid_from, nil] }
  end

  def pick_vulnerabilities(computer, time=nil)
    apps = computer.applications_at(time)
    
    possible_vulns = apps.map { |a| a.vulns }.flatten.uniq
    count = (0..possible_vulns.length).random
    possible_vulns.randomize.first(count).map { |v| [v, time, nil] }
  end

  def pick_vulnerabilities_to_match_score(computer, desired_score, tolerance=0.5, time=nil)
    # This is kinda hacky and certainly nondeterministic, but it's better than
    # trying to find an exact fit, which requires solving the NP-complete
    # "subset sum problem", a special case of the knapsack problem.
    #
    # It has the additional quality of picking something "close" in most cases
    # which such a solution is possible.
  
    apps = computer.applications_at(time)
    return [] unless apps && !apps.empty?
    
    possible_vulns = apps.map { |a| a.vulns }.flatten.uniq
    return [] if possible_vulns.empty?

    vulns = Set.new(computer.vulnerabilities_at(time))
    total_score = vulns.map(&:cvss_base_score).sum || 0
    
    iterations = 50
    while (total_score - desired_score).abs > tolerance && iterations > 0
      iterations -= 1
    
      if total_score > desired_score + tolerance
        v = vulns.to_a.random
        score = v.cvss_base_score
        next if total_score - score < desired_score * 0.8
        vulns.delete(v)
        total_score -= score
        next if total_score > desired_score + tolerance
      end
    
      v = possible_vulns.random
      next if vulns.member?(v)
      score = v.cvss_base_score
      next if total_score + score > desired_score * 2
      vulns << v
      total_score += score
    end
  
    vulns.map { |v| [v, time, nil]}
  end
end

#!/usr/bin/env ruby

require 'lib/computer_generator'
require 'lib/group_tree_generator'
require 'lib/db_importer'

require 'rubygems'
require 'ip_admin'

require 'lib/core_extensions'

# Hardcoded paths
groups_dir = 'groups/computers'

# Command line options
config_filename = ARGV[0]
unless config_filename
  puts "Usage: #{$0} <config filename>"
end

config = YAML::load(File.new(config_filename, 'r'))

# Get some config vars
computer_count = (config['computer count'] ||= 1)



# Initialize the PRNG
srand (config['prng seed'] || Time.now).to_i

class CGGenerator
  def initialize(name_generator, addr_pool, computer_generator)
    @name_generator = name_generator
    @addr_pool = addr_pool
    @computer_generator = computer_generator
  end
  
  def make_group(count, profiles, base)
    names = @name_generator.generate_many(count)
    if profiles.length < count
      profiles *= [2, ((count + 1) / profiles.length)].max
    end
    
    # Allocate some IP addresses
    addrs = @addr_pool[0..count]
    @addr_pool = @addr_pool[count..-1]
    
    group_gen = ComputerGroupGenerator.new({ 'ip_address' => addrs,
                                             'netbios_name' => names,
                                             'profiles' => profiles})

    computers = group_gen.generate(count, base)
    
    generator_options = { :valid_from => Time.now, :target_cvss_score => 6.0 }
    
    computers.map! { |c| @computer_generator.generate(c, c.delete('profiles'),
                            generator_options) }
  end
end

class DBGenerator
  def initialize(config, computer_defs)
    # XXX
    @computers_sql_file = File.new('computers.sql', 'w')

    @config = config
    @computer_defs = computer_defs
    
    # Set up the random name generator
    adjs = File.new('sources/words/adjectives.txt', 'r').readlines.map(&:chop)
    nouns = File.new('sources/words/nouns.txt', 'r').readlines.map(&:chop)
    @namegen = RandomNameGenerator.new(:patterns => [[:adjective, :noun]],
                                       :sources => { :adjective => adjs,
                                                     :noun => nouns },
                                       :map => lambda { |s| s.strip.gsub(/\[\][.\/\\:|<>+=;,]/, '').upcase[0..32] })

    @days = @config['days'] || 0
    @start_date = @days.days.ago
  end
  
  def generate
    groups, counts = pick_computer_groups
    
    ids = ComputerGroupDBImporter.import(File.new('computer_groups.sql', 'w')) do |cgdb|
      cgdb.write_groups(groups)
    end

    group_counts = counts.map { |key, count| [ids[key], count] }
    
    make_computers_for_groups(group_counts)
  end
  
  def pick_computer_groups
    config_defaults = { 'min_cluster_size' => 100,
                        'max_cluster_size' => 1000000 }

    config = GroupTreeConfig.new('groups/geo_distribution/profiles/global.yaml',
                                 config_defaults)
    corpus = GroupCorpus.new('groups/geo_distribution/geography')
    picker = GroupPicker.new(corpus, config)

    ents = picker.pick(@config['computer count'])
    [ picker.make_computer_groups(ents.keys.map { |e| corpus.entities[e] }, ents),
      ents ]
  end
  
  def make_computers_for_groups(counts)
    gen = ComputerGenerator.new(@computer_defs)

    ComputerDBImporter.import(@computers_sql_file, @computer_defs, @start_date) do |importer|
      counts.each do |group_id, count|
        addrs = IPAdmin.range(:Boundaries => ["10.#{group_id}.0.0", "10.#{group_id}.255.255"], :Inclusive => false, :Limit => 30000)
        cg_gen = CGGenerator.new(@namegen, addrs, gen)
        group = make_group(cg_gen, group_id, count)
        group.each { |c| importer.write_computer(c) }
      end
    end
  end
  
  def make_group(cg_gen, group_id, count)
    groups = [group_id]

    profiles = [['m_win_1', 'xp_sp2_desktop_1']] * 10 + [['h_win_2']] * 5 + [['l_win_1', 'w2k_sp4_desktop_2']] * 30 + \
               [['macbook_pro']] * 5 + [['m_win_3', 'w2k_sp4_desktop_1']] * 50

    group = cg_gen.make_group(count, profiles, { 'groups' => groups })

    # If we're generating multiple days of data, do some mutations to the hosts.
    #if @days > 0
    #  group.each { |c| gen.mutate(c, @start_date, Time.now, @days) }
    #end

    #puts group.map { |c| c.to_h }.to_yaml
  end
end

comp_defs = ComputerDefs.new(groups_dir)
g = DBGenerator.new(config, comp_defs)
g.generate

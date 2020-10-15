#!/usr/bin/env ruby

require 'rexml/document.rb'
require 'rexml/streamlistener.rb'
include REXML

class CachedAppGraph
  def initialize
    publishes = AppRelationshipType.lookup_type :publishes
    has_version = AppRelationshipType.lookup_type :is_instantiated_by
    
    puts 'Fetching apps...'
    apps = App.find :all, :include => :outgoing_edges

    puts 'Crunching apps...'
    @apps_by_id = apps.index_by &:id
    
    vendors = apps.find_all { |a| a.outgoing_edges.to_a.find {|e| e.app_relationship_type_id == publishes }}
    
    @vendors = {}
    vendors.each do |vendor|
      published = {}
      
      vendor.outgoing_edges.each do |edge|
        if edge.app_relationship_type_id == publishes
          app = @apps_by_id[edge.related_app_id]
          versions = app.outgoing_edges.to_a.find_all { |app_edge| app_edge.app_relationship_type_id == has_version }.map { |app_edge| @apps_by_id[app_edge.related_app_id] }
          published[app.name.downcase] = \
            { :app => app,
              :versions => versions.index_by { |ver| ver.name.downcase } }
        end
      end
      
      @vendors[vendor.name.downcase] = { :app => vendor, :published => published }
    end
    
    puts 'Done.'
  end
  
  def find_or_create(vendor_name, app_name, version_name)
    if a = find(vendor_name, app_name, version_name)
      return a
    end
    
    unless app = find(vendor_name, app_name)
      unless v = find_vendor(vendor_name)
        v = App.new(:name => vendor_name)
        v.save!
        @apps_by_id[v.id] = v
        @vendors[vendor_name.downcase] = { :app => v, :published => {} }
        puts "Created missing vendor: #{vendor_name}"
      end
      
      app = v.add_published_app(app_name)
      @apps_by_id[app.id] = app
      @vendors[vendor_name.downcase][:published][app.name.downcase] = \
        { :app => app, :versions => {} }
      puts "Created missing application: #{vendor_name} #{app_name}"
    end
    
    return app if version_name.nil? || version_name == ''
    
    returning ver = app.add_version(version_name) do
      @apps_by_id[ver.id] = ver
      @vendors[vendor_name.downcase][:published][app.name.downcase][:versions][version_name.downcase] = ver
      puts "Created missing version: #{vendor_name} #{app_name} #{version_name}"
    end
  end
  
  def find_vendor(vendor_name)
    return nil unless v = @vendors[vendor_name.downcase]
    v[:app]
  end
  
  def find(vendor_name, app_name, version_name=nil)
    return nil unless v = @vendors[vendor_name.downcase]
    return nil unless a = v[:published][app_name.downcase]
    return a[:app] if version_name.nil? || version_name == ''
    
    return a[:versions][version_name.downcase] || a[:versions][app_name.downcase + ' ' + version_name.downcase]
  end
end

class NVDListener
  include StreamListener

  def initialize
    @tag_stack = []
  end

  def entry_start(attrs)
    @entry = attrs
    @entry['descriptions'] = {}
    @entry['refs'] = []
    @entry['apps'] = {}
  end
  
  def entry_end()
    process_entry(@entry)
    @entry = nil
  end
  
  def descript_start(attrs)
    @descript_source = attrs['source']
    @entry['descriptions'][@descript_source] = ''
  end
  
  def descript_text(text)
    @entry['descriptions'][@descript_source] += text
  end
  
  def refs_start(attrs)
    @refs = []
  end
  
  def refs_end
    @entry['refs'] = @refs
  end
  
  def ref_start(attrs)
    @ref = attrs
    @ref['body'] = ''
  end
  
  def ref_text(text)
    @ref['body'] += text
  end
  
  def ref_end
    @refs.push(@ref)
  end
  
  def prod_start(attrs)
    @product = attrs
    @product['versions'] = []
  end
  
  def prod_end
    @entry['apps'][@product['vendor']] ||= {}
    @entry['apps'][@product['vendor']][@product['name']] ||= []
    @entry['apps'][@product['vendor']][@product['name']] += @product['versions']
  end
  
  def vers_start(attrs)
    # XXX: Should deal with the "prev" flag as well.
    @product['versions'].push(attrs['num'])
  end
    
  def tag_start(name, attrs)
    @tag_stack.push(name)
    method = (name + '_start').to_sym
    if respond_to?(method)
      send(method, attrs)
    end
  end
  
  def tag_end(name)
    @tag_stack.pop()
    method = (name + '_end').to_sym
    if respond_to?(method)
      send(method)
    end
  end
  
  def text(text)
    return unless @tag_stack != []
    
    method = (@tag_stack.last + '_text').to_sym
    if respond_to?(method)
      send(method, text)
    end
  end
end

class NVDImporter < NVDListener
  attr_reader :vulns, :advisories, :bindings

  def initialize(vuln_seq, advisory_seq)
    super()
    @vulns = []
    @advisories = []
    @bindings = []
    @vuln_seq = vuln_seq
    @advisory_seq = advisory_seq
    @app_cache = CachedAppGraph.new
    @i = 0
  end
  
  def process_entry(entry)
    @i += 1
    
    if @i % 100 == 0
      puts @i
    end
    
    if entry['type'] != 'CVE'
      return
    end
    
    if entry['descriptions'] != {}:
      name = entry['name'] + ': ' + entry['descriptions'].to_a[0][1]
    else
      name = entry['name']
    end
    
    vuln_id = @vuln_seq
    @vuln_seq += 1
    
    advisory_id = @advisory_seq
    @advisory_seq += 1
    
    severity_id =
      case entry['severity']
      when 'High'
        4
      when 'Medium'
        2
      when 'Low'
        1
      else
        3
      end
      
    @vulns << [vuln_id, name, severity_id, entry['published'], entry['CVSS_score'], 'Imported from NVD']
    @advisories << [advisory_id, vuln_id, 1, entry['name']]
    
    entry['apps'].each do |vendor_name, apps|
      apps.each do |app_name, versions|
        versions.each do |version_name|
          ver_app = @app_cache.find_or_create(vendor_name, app_name, version_name)
          @bindings << [vuln_id, ver_app.id]
        end
      end
    end
  end
end

vuln_seq = ActiveRecord::Base.connection.select_value("SELECT max(id) FROM vulns").to_i + 1
advisory_seq = ActiveRecord::Base.connection.select_value("SELECT max(id) FROM vuln_advisories").to_i + 1

begin
  listener = NVDImporter.new(vuln_seq, advisory_seq)
  ARGV.each do |filename|
    f = File.new(filename)
    REXML::Document.parse_stream(f, listener)
  end
rescue Exception => e
  puts "Exception: #{e.class}: #{e.message}\n\t#{e.backtrace.join("\n\t")}"
  exit 1
end



def quote(str)
  ActiveRecord::Base.connection.quote(str)
end

def print_insert(f, table, cols, entries)
  entries = entries.map { |e| "(#{e.map { |v| quote(v) }.join(',')})" }.join(',')
  f.write("INSERT INTO #{table} (#{cols.join(',')}) VALUES #{entries};\n")
end

def split_and_print_entries(f, table, cols, entries, size=2000)
  while not entries.nil? and not entries.empty?
    print_insert(f, table, cols, entries[0..size - 1])
    entries = entries[size..-1]
  end
end

vf = File.new('vulns.sql', 'w')
af = File.new('vuln_advisories.sql', 'w')
avf = File.new('apps_vulns.sql', 'w')

split_and_print_entries(vf, 'vulns', ['id', 'name', 'vuln_severity_id', 'publish_date', 'cvss_base_score', 'description'], listener.vulns)
split_and_print_entries(af, 'vuln_advisories', ['id', 'vuln_id', 'vuln_advisory_publisher_id', 'advisory_id'], listener.advisories)
listener.bindings.uniq!
split_and_print_entries(avf, 'apps_vulns', ['vuln_id', 'app_id'], listener.bindings)

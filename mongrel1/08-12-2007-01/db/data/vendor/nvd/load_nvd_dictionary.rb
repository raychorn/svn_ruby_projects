#!/usr/bin/env ruby

require 'csv'

filename = ARGV[0]

@vendors = {}

def get_vendor(name)
  @vendors[name.downcase] ||= { :name => name, :apps => {} }
end

def get_app(vendor, name)
  v = get_vendor(vendor)
  v[:apps][name.downcase] ||= { :name => name, :versions => [] }
end

f = File.new(filename, 'r')

def csv_iter(f)
  f.each_line do |line|
    begin
      yield CSV.parse_line(line)
    rescue EOFError
      return
    end
  end
end

csv_iter(f) do |entry|
  vendor_name = entry[0]
  app_name = entry[1]
  app_version = entry[2]
  
  next if vendor_name.blank? or app_name.blank?
  
  app = get_app(vendor_name, app_name)
  
  app[:versions].push(app_version) unless app_version.blank?
end

p2a_rt = AppRelationshipType.find_by_name('publishes').id
a2v_rt = AppRelationshipType.find_by_name('is instantiated by').id

app_seq = 1
app_entries = []
rel_entries = []

def quote(str)
  ActiveRecord::Base.connection.quote(str)
end

@vendors.values.each do |vendor_def|
  vendor_id = app_seq
  app_seq += 1
  
  app_entries << [vendor_id, quote(vendor_def[:name])]

  vendor_def[:apps].values.each do |app_def|
    app_id = app_seq
    app_seq += 1
    
    app_entries << [app_id, quote(app_def[:name])]

    rel_entries << [p2a_rt, vendor_id, app_id]
        
    app_def[:versions].each do |version_name|
      ver_id = app_seq
      app_seq += 1
      
      app_entries << [ver_id, quote(app_def[:name] + ' ' + version_name)]
      
      rel_entries << [a2v_rt, app_id, ver_id]
    end
  end
end

def print_insert(table, cols, entries)
  entries = entries.map { |e| "(#{e.join(',')})" }.join(',')
  puts "INSERT INTO #{table} (#{cols.join(',')}) VALUES #{entries};"
end

def split_and_print_entries(table, cols, entries, size=4000)
  while not entries.nil? and not entries.empty?
    print_insert(table, cols, entries[0..size - 1])
    entries = entries[size..-1]
  end
end

split_and_print_entries('apps', ['id', 'name'], app_entries)
split_and_print_entries('app_relationships', ['app_relationship_type_id', 'app_id', 'related_app_id'], rel_entries)

#app_values = app_entries.map { |app| "(#{app.join(',')})" }
#rel_values = rel_entries.map { |rel| "(#{rel.join(',')})" }

#puts "INSERT INTO apps (id, name) VALUES #{app_values.join(', ')};"
#puts "INSERT INTO app_relationships (app_relationship_type_id, app_id, related_app_id) VALUES #{rel_values.join(', ')};"

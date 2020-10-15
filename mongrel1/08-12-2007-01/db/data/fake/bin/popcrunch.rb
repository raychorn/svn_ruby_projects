#!/usr/bin/env ruby

require 'csv'

def lower_under(name)
  name.downcase.gsub(/[^a-zA-Z]/, '_')
end

def drop_last_word(str)
  space_index = str.rindex ' '
  return str if space_index.nil? || space_index < 2
  
  str[0..space_index - 1]
end

states = Hash.new { |h,k| h[k] = [] }
threshold = ARGV[1].to_i
threshold = 15000 if ARGV[1].nil?

CSV.foreach ARGV[0] do |sumlev, state_code, county_code, place_code, cousub,
                        place_name, state_name, pb2000, p2000, p2001, p2002, p2003,
                        p2004, p2005|
  next unless sumlev == '162' && p2005.to_i >= threshold

  place_name = drop_last_word(place_name)
  states[state_name] << [place_name, p2005]
  
  puts "#{place_name}, #{state_name}"
end

states.each do |state_name, places|
  state_lname = lower_under(state_name)
  file = File.new(state_lname + '.yaml', 'w')
  file.puts "#{state_lname}:"
  file.puts "  title: #{state_name}"
  file.puts "  subgroups:"
  
  places.each do |place_name, population|
    file.puts "  - #{state_lname}_#{lower_under(place_name)}"
  end
  
  file.puts ""
  
  places.each do |place_name, population|
    file.puts "#{state_lname}_#{lower_under(place_name)}:"
    file.puts "  title: #{place_name}"
    file.puts "  type: city"
    file.puts "  population: #{population}"
    file.puts ""
  end
end

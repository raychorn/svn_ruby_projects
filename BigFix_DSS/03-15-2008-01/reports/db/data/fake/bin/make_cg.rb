#!/usr/bin/env ruby

require 'lib/computer_generator'
require 'lib/db_importer'

require 'rubygems'
require 'ip_admin'

require 'lib/core_extensions'



computer_count = ARGV[0] ? ARGV[0].to_i : 1
groups = ARGV[1] ? [ARGV[1].to_i] : []
days_ago = ARGV[2] ? ARGV[2].to_i : 0

srand Time.now.to_i

groups_dir = 'groups/computers'
adjs = File.new('sources/words/adjectives.txt', 'r').readlines.map(&:chop)
nouns = File.new('sources/words/nouns.txt', 'r').readlines.map(&:chop)

addrs = IPAdmin.range(:Boundaries => ['10.0.0.0', '10.255.255.255'], :Inclusive => false, :Limit => computer_count)
namegen = RandomNameGenerator.new(:patterns => [[:adjective, :noun]],
                                  :sources => { :adjective => adjs,
                                                :noun => nouns },
                                  :map => lambda { |s| s.strip.gsub(/\[\][.\/\\:|<>+=;,]/, '').upcase[0..32] })
names = namegen.generate_many(computer_count)

profiles = [['m_win_1', 'xp_sp2_desktop_1']] * 10 + [['h_win_2']] * 5 + [['l_win_1', 'w2k_sp4_desktop_2']] * 30 + \
           [['macbook_pro']] * 5 + [['m_win_3', 'w2k_sp4_desktop_1']] * 50

if profiles.length < computer_count
  profiles = profiles * ((computer_count + 1) / profiles.length)
end

group_gen = ComputerGroupGenerator.new({ 'ip_address' => addrs,
                                         'netbios_name' => names,
                                         'profiles' => profiles})
group = group_gen.generate(computer_count, { 'groups' => groups })
                                  
comp_defs = ComputerDefs.new(groups_dir)
gen = ComputerGenerator.new(comp_defs)

group.map! { |c| gen.generate(c, c.delete('profiles'), :valid_from => days_ago.days.ago,
                              :target_cvss_score => 6.0) }

# If we're generating multiple days of data, do some mutations to the hosts.
if days_ago > 0
  group.each { |c| gen.mutate(c, days_ago.days.ago, Time.now, days_ago) }
end

puts group.map { |c| c.to_h }.to_yaml

f = File.new('computers.sql', 'w')
ComputerDBImporter.import(f, comp_defs, days_ago.days.ago) do |importer|
  group.each { |c| importer.write_computer(c) }
end

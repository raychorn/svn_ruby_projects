#!/usr/bin/ruby

require 'lib/group_tree_generator'

srand Time.now.to_i

config_defaults = { 'min_cluster_size' => 100,
                    'max_cluster_size' => 1000000 }

config = GroupTreeConfig.new(ARGV[0], config_defaults)
corpus = GroupCorpus.new(ARGV[1])
picker = GroupPicker.new(corpus, config)

ents = picker.pick(ARGV[2].to_i)
groups = picker.make_computer_groups(ents.keys.map { |e| corpus.entities[e] }, ents)

puts groups.to_yaml
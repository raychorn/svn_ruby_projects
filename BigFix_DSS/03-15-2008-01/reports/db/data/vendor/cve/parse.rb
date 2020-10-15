#!/usr/bin/env ruby

require 'rexml/document.rb'
require 'rexml/streamlistener.rb'
include REXML

class CVEListener
  include StreamListener

  attr_reader :items

  def initialize
    @tag_stack = []
  end

  def item_start(attrs)
    @item = { 'name' => attrs['name'],
              'status' => '',
              'desc' => '' }
  end
  
  def item_end()
    process_item(@item)
    @item = nil
  end
  
  def refs_start(attrs)
    @refs = []
  end
  
  def refs_end
    @item['refs'] = @refs
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
  
  def status_text(text)
    @item['status'] += text
  end
  
  def desc_text(text)
    @item['desc'] += text
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
    method = (@tag_stack.last + '_text').to_sym
    if respond_to?(method)
      send(method, text)
    end
  end
end

class CVEImporter < CVEListener
  def process_item(item)
    if item['refs'] != []:
      name = item['refs'][0]['body']
    else
      name = item['name'] + ': ' + item['desc']
    end
    
    v = Vuln.new(:name => name, :vuln_severity_id => 1, :publish_date => '2000-01-01', :description => 'Imported from CVE')
    v.save!
    va = VulnAdvisory.new(:vuln_id => v.id, :vuln_advisory_publisher_id => 1, :advisory_id => item['name'])
    va.save!
    
    puts name
  end
end

listener = CVEImporter.new
f = File.new(ARGV[0])

Vuln.delete_all

REXML::Document.parse_stream(f, listener)

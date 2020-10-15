require File.dirname(__FILE__) + '/../test_helper'

require 'import'

class ImportDSSDatabaseTest < Test::Unit::TestCase
  fixtures :computers
  fixtures :datasources
  
  def setup
    @dssDatabase = Import::DSSDatabase.new
  end
  
  def test_add_datasource_computer
    assert_difference Computer.find(1).datasources, :count do
      @dssDatabase.add_datasource_computer(1, 9980, 1)
    end
  end
  
  def test_add_datasource_computers
    assert_difference Computer.find(1).datasources, :count do
      @dssDatabase.add_datasource_computers(1, { 9980 => 1 })
    end
  end
end

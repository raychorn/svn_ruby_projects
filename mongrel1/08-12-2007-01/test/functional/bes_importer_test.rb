require File.dirname(__FILE__) + '/../test_helper'
require 'mocha'
require 'import/bes'

include Mocha::AutoVerify

class BESImporterTest < Test::Unit::TestCase
  @@fixlet_records = \
    [ [ 5000, 85, 105, nil, nil, false ],
      [ 5000, 85, 106, nil, 15.days.ago, true ],
      [ 5001, 22, 3, 10.days.ago, 15.days.ago, false ]
     ]
  
  @@app_records = \
    [ [ 5000, ['WinRAR archiver', 'BigFix Enterprise Console - 7.0.1.275' ]],
      [ 5001, ['Adobe Flash Player', 'PCHealth', 'Adobe Acrobat 8 Standard - 8.0.0' ]] 
     ]
  
  @@os_records = \
    [ [ 5000, ['Microsoft Windows XP Professional Service Pack 2', '5.1.2600' ]],
      [ 5001, ['Microsoft Windows 2000 Server Service Pack 4', '5.0.2195' ]]
     ]
  
  @@ip_records = \
    [ [ 5000, '192.168.0.1' ],
      [ 5001, '192.168.0.2' ]
     ]

  @@name_records = \
    [ [ 5000, 'FOO' ],
      [ 5001, 'BAR' ]
     ]
  
  def setup
    fixlet_records = \
      @@fixlet_records.map do |cid, siteid, fixletid, lastrel, lastnonrel, isrel|
        { 'computerid' => cid.to_s, 'siteid' => siteid.to_s, 'fixletid' => fixletid.to_s,
          'lastbecamerelevant' => lastrel && DateTime.parse(lastrel.strftime('%Y%m%dT%H%M%S')),
          'lastbecamenonrelevant' => lastnonrel && DateTime.parse(lastnonrel.strftime('%Y%m%dT%H%M%S')),
          'isrelevant' => isrel ? '1' : '0' }
      end
    
    app_records = \
      @@app_records.map { |cid, appnames| { 'computerid' => cid.to_s, 'resultstext' => appnames.join("\n") } }
    
    os_records = \
      @@os_records.inject([]) do |recs, (cid, osparts)|
        osparts.each do |ospart|
          recs << { 'computerid' => cid.to_s, 'resultstext' => ospart }
        end
        recs 
      end
     
    ip_records = \
      @@ip_records.map { |cid, ipaddr| { 'computerid' => cid.to_s, 'resultstext' => ipaddr } }

    name_records = \
      @@ip_records.map { |cid, name| { 'computerid' => cid.to_s, 'resultstext' => name } }

    sitemap = { 'url1' => 1, 'url2' => 2, 'url22' => 22, 'url85' => 85,
                1 => 'url1', 2 => 'url2', 22 => 'url22', 85 => 'url85' }

    @bes_db = mock()
    @bes_db.stubs(:get_fixlet_results).returns(fixlet_records)
    @bes_db.stubs(:get_windows_apps).returns(app_records)
    @bes_db.stubs(:get_os_names).returns(os_records)
    @bes_db.stubs(:get_ip_addresses).returns(ip_records)
    @bes_db.stubs(:get_computer_names).returns(name_records)
    @bes_db.stubs(:site_url_mapping).returns(sitemap)
  end
  
  ## XXX: Replace me with real test cases.
  def test_ok
    assert true
  end
  
  ## XXX: Disabled due to bit-rot.
  def zz_test_import_vuln_records
    fake_vuln_records = { 1 => [false, Time.now], 2 => [true, 2.days.ago] }
    fake_vuln_records_2 = { 1 => [true, Time.now], 2 => [true, 2.days.ago] }
    
    dss_database = Import::DSSDatabase.new
    dss_database.stubs(:get_datasource_computer_id_map).with(1).returns({})
    
    Import::BES::CatalogMapping.any_instance.stubs(:site_mapping).returns({})
    
    Import::BES::Transformer.any_instance.stubs(:transform_fixlet_results).returns({ 5 => fake_vuln_records })
    
    importer = Import::BES::Importer.new(@bes_db, dss_database, nil, 1)
    assert_difference ComputerVuln, :count do
      importer.import_vuln_records
    end

    # Importing them again should have no effect.
    assert_no_difference ComputerVuln, :count do
      importer.import_vuln_records
    end

    # Making vuln #1 as active should create a new row.
    Import::BES::Transformer.any_instance.stubs(:transform_fixlet_results).returns({ 5 => fake_vuln_records_2 })
    assert_difference ComputerVuln, :count do
      importer.import_vuln_records
    end
  end

  ## XXX: Disabled due to bit-rot.
  def zz_test_import_property_records
    dss_database = Import::DSSDatabase.new
    dss_database.stubs(:get_datasource_computer_id_map).with(1).returns({})
    
    Import::BES::CatalogMapping.any_instance.stubs(:site_mapping).returns({})
    
    importer = Import::BES::Importer.new(@bes_db, dss_database, nil, 1)
    assert_difference ComputerProperty, :count, 4 do
      importer.import_all_property_records
    end
  end
end

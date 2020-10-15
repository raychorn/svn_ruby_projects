require File.dirname(__FILE__) + '/../test_helper'
require 'mocha'
require 'import/bes'

include Mocha::AutoVerify

class BESTransformerTest < Test::Unit::TestCase
  def test_transform_fixlet_results
    catalog_mapping = mock()
    catalog_mapping.expects(:vuln_mapping).returns(
      { 1333 => { 3 => [2600],
                  4 => [2601, 2602],
                  5 => [2603]
                 },
        1334 => { 8 => [2603] }
       })
    catalog_mapping.expects(:fixlet_mapping).returns(
      { 2600 => [[1333, 3]],
        2601 => [[1333, 4]],
        2602 => [[1333, 4]],
        2603 => [[1334, 8], [1333, 5]]
       })
    catalog_mapping.expects(:site_mapping).returns({ 'url' => 1333, 'url2' => 1334 })
    computer_id_mapping = mock()
    computer_id_mapping.stubs(:d2i).with(1500).returns(1)
    computer_id_mapping.stubs(:d2i).with(1505).returns(2)
    site_url_mapping = { 5 => 'url', 6 => 'url2' }
    transformer = Import::BES::Transformer.new(catalog_mapping, computer_id_mapping,
                                               site_url_mapping)
    
    time1 = Time.parse('2007-06-01T15:01:00-07:00')
    time2 = Time.parse('2007-06-05T05:18:00-07:00')
    time3 = Time.parse('2007-07-25T15:20:00-07:00')
    time4 = Time.parse('2007-07-25T15:25:00-07:00')
    time5 = Time.parse('2007-07-25T15:28:00-07:00')    
    
    assert_equal \
      [{ 1 => { 2600 => [true, time4.to_time],
               2601 => [false, time5.to_time],
               2602 => [false, time5.to_time],
              },
        2 => {}
        },
       [ [2, 2603, [[1334, 8], [1333, 5]]]]
       ],
      
      transformer.transform_fixlet_results(
      [ ['1500', '5', '3', nil, ODBC::TimeStamp.new(time4), '1'],

        # This fixlet maps to two vulnerabilities.
        ['1500', '5', '4', ODBC::TimeStamp.new(time5),
         ODBC::TimeStamp.new(time3), '0'],

        # This site does not exist.
        ['1500', '8', '4', nil, ODBC::TimeStamp.new(time5), '1'],

        # This fixlet is not in the mapping.
        ['1500', '5', '400', nil, ODBC::TimeStamp.new(time5), '1'],

        # This fixlet is not relevant.
        ['1505', '6', '8', ODBC::TimeStamp.new(time2),
         ODBC::TimeStamp.new(time1), '0']
       ])
  end
  
  def test_transform_app_results
    app_mapping = Import::Lexer.new([[/Windows NT/, 1],
                                     [/MSIE 6.0/, 2],
                                     [/Windows Vista Home Basic/, 3],
                                     [/WinAmp/, 4],
                                     [/iTunes/, 5]])
    catalog_mapping = mock()
    catalog_mapping.expects(:app_mapping).returns(app_mapping)
    catalog_mapping.stubs(:site_mapping).returns({})
    computer_id_mapping = mock()
    computer_id_mapping.stubs(:d2i).with(1500).returns(1)
    computer_id_mapping.stubs(:d2i).with(1505).returns(2)
    transformer = Import::BES::Transformer.new(catalog_mapping, computer_id_mapping, nil)
    
    assert_equal transformer.transform_app_results(
        [['1500', "Windows NT\nMSIE 6.0\nAdobe Acrobat\n"],
         ['1505', "Windows Vista Home Basic\nWinAmp\niTunes\n"]
        ]),
      { 1 => Set.new([1, 2]),
        2 => Set.new([3, 4, 5]) }
  end
  
  def test_transform_os_results
    os_mapping = Import::Lexer.new([[/Mac OS X 10.4.9/, 1],
                                    [/Windows Vista Home Basic/, 2],
                                    [/Windows NT 4.0 Service Pack 2/, 3],
                                    [/Windows XP Professional Service Pack 2/, 4]
                                   ])
    catalog_mapping = mock()
    catalog_mapping.expects(:os_name_mapping).returns(os_mapping)
    catalog_mapping.stubs(:site_mapping).returns({})
    computer_id_mapping = mock()
    computer_id_mapping.stubs(:d2i).with(1500).returns(1)
    computer_id_mapping.stubs(:d2i).with(1505).returns(2)
    transformer = Import::BES::Transformer.new(catalog_mapping, computer_id_mapping, nil)
    
    assert_equal transformer.transform_os_results(
        [['1500', 'Windows NT 4.0 Service Pack 2'],
         ['1505', 'Mac OS X'],
         ['1505', '10.4.9']
        ]),
      { 1 => 3, 2 => 1 }
  end
  
  def test_transform_property_results
    catalog_mapping = mock()
    catalog_mapping.stubs(:site_mapping).returns({})
    computer_id_mapping = mock()
    computer_id_mapping.stubs(:d2i).with(1500).returns(1)
    computer_id_mapping.stubs(:d2i).with(1505).returns(2)
    transformer = Import::BES::Transformer.new(catalog_mapping, computer_id_mapping, nil)

    assert_equal transformer.transform_property_results(
        [['1500', '10.1.1.5'],
         ['1505', '10.1.1.6']
         ]),
      { 1 => '10.1.1.5', 2 => '10.1.1.6' }
  end
end

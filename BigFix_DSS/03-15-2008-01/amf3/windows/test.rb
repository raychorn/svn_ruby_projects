require 'amf3'
require 'date'
require 'test/unit'
require 'rexml/document'

class TestClass
  attr_accessor :a, :b
  
  def self.get_attributes
    [:a, :b]
  end
  
  def initialize(a, b)
    @a = a
    @b = b
  end
end

class TransformedClass
  attr_accessor :a
  
  def initialize(a)
    @a = a
  end
end

class AMF3WriterTest < Test::Unit::TestCase
  def setup
    @output = ''
    @writer = AMF3::Writer.new(@output, { 'TestClass' => 'com.bigfix.TestClass' },
              lambda { |x| TransformedClass === x ? [nil, x.a] : nil })
  end
  
  def marshall(obj)
    @writer << obj
    @writer.flush
    r = @output.dup
    @output[0..-1] = ''
    return r
  end

  def test_atoms
    assert_equal "\x01", marshall(nil)
    assert_equal "\x02", marshall(false)
    assert_equal "\x03", marshall(true)
  end
  
  def test_integer
    assert_equal "\x04\x01", marshall(1)
    assert_equal "\x04\xff\xff\xff\xff", marshall(-1)
    assert_equal "\x04\x00", marshall(0)
    assert_equal "\x04\x81\x54", marshall(212)
    assert_equal "\x04\x86\xca\x3f", marshall(107839)
    assert_equal "\x04\xc0\x80\x80\x00", marshall(-268435456)
    assert_equal "\x04\xbf\xff\xff\xff", marshall(268435455)
  end
  
  def test_number
    assert_equal "\x05\x3f\xf8\x00\x00\x00\x00\x00\x00", marshall(1.5)
    assert_equal "\x05\x41\xb0\x00\x00\x00\x00\x00\x00", marshall(268435456)
  end
  
  def test_string
    assert_equal "\x06\x0dabcdef", marshall('abcdef')
    
    # Test a long string
    assert_equal "\x06\x90\x01" + 'x' * 1024, marshall('x' * 1024)
    
    # Test proper "modified UTF-8" encoding of NUL
    assert_equal "\x06\x05\xc0\x80", marshall("\x00")
    
    # Test proper "modified UTF-8" CESU-8 encoding of Unicode characters
    # outside the Basic Multilingual Plane
    assert_equal "\x06\x19abc\xed\xa0\x81\xed\xb0\x80def", marshall("abc\xf0\x90\x90\x80def")

    # Test error case for CESU-8 encoding transform: String too short
    assert_equal "\x06\x07abc", marshall("abc\xf0\x90\x90")

    # Test error case for CESU-8 encoding transform: Overly-long encoding
    assert_equal "\x06\x0dabcdef", marshall("abc\xf0\x80\x90\x80def")
  end
  
  def test_xml
    assert_equal "\x07\x0d<xml/>", marshall(REXML::Document.new("<xml/>"))
  end
  
  def test_date
    assert_equal "\x08\x01\x42\x71\x37\xf1\x3a\x40\x00\x00", marshall(Date.civil(2007,07,01))
    assert_equal "\x08\x01\x42\x71\x38\x1d\x6f\xe0\xd0\x00", marshall(Time.gm(2007,07,01,12,52,37,5000))
    assert_equal "\x08\x01\x42\x71\x38\x04\x6a\x9a\x80\x00", marshall(DateTime.new(2007,07,01,05,35,21))
  end
  
  def test_array
    assert_equal "\x09\x07\x01\x04\x00\x04\x01\x04\x02", marshall([0, 1, 2])
    assert_equal "\x09\x05\x01\x04\x00\x09\x05\x01\x04\x01\x04\x02", marshall([0, [1, 2]])
  end
  
  def test_hash
    assert_equal "\x0a\x33\x01\x03a\x03b\x07foo\x04\x01\x04\x02\x04\x03", marshall({ 'a' => 1, 'b' => 2, 'foo' => 3 })
  end
  
  def test_object
    assert_equal "\x0a\x23\x29com.bigfix.TestClass\x03a\x03b\x04\x01\x04\x02", marshall(TestClass.new(1, 2))
  end
  
  def test_transformed_object
    assert_equal "\x0a\x13\x01\x03a\x04\x05", marshall(TransformedClass.new({'a' => 5}))
  end
  
  def test_string_reference
    marshall('abcdef')
    assert_equal "\x06\x00", marshall('abcdef')

    marshall('foobar')
    assert_equal "\x06\x02", marshall('foobar')

    marshall('foo')
    assert_equal "\x06\x04", marshall('foo')
  end
  
  def test_array_reference
    marshall([0, 1, 2])
    assert_equal "\x09\x00", marshall([0, 1, 2])
    
    marshall([0, [1, 2]])
    assert_equal "\x09\x02", marshall([0, [1, 2]])
    
    assert_equal "\x09\x05\x01\x04\x02\x09\x04", marshall([2, [1, 2]])
  end
  
  def test_object_reference
    v = { 'a' => 'qrz', 'b' => 123 }
    marshall(v)
    assert_equal "\x0a\x00", marshall(v)
    
    v = { 'x' => 0, 'c' => 1 }
    marshall(v)
    assert_equal "\x09\x09\x01\x0a\x02\x0a\x02\x0a\x02\x0a\x02", marshall([v, v, v, v])
    assert_equal "\x09\x04", marshall([v, v, v, v])
  end
  
  def test_object_field_reference
    marshall('abc')
    assert_equal "\x06\x00", marshall('abc')
    assert_equal "\x0a\x23\x01\x00\x07qrz\x04\x01\x04\x02", marshall({ 'qrz' => 2, 'abc' => 1 })
  end
  
  def test_object_class_reference
    assert_equal "\x0a\x23\x01\x03a\x03b\x04\x01\x04\x02", marshall({ 'a' => 1, 'b' => 2 })
    assert_equal "\x0a\x01\x04\x00\x04\x01", marshall({ 'a' => 0, 'b' => 1 })
  end
end

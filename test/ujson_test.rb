require 'test/unit'
require 'ujson.rb'

class UJSONTest < Test::Unit::TestCase
  ### OBJECTS
  def test_empty_object
    assert UJSON.parse('{}'), 'Error processing \'{}\''
  end
  def test_object_string_value
    object = UJSON.parse('{"string":"string_value"}')
    assert object, 'Error processing an object with string value' 
    assert_equal 'string_value', object["string"], 'Wrong value parsed'
  end
  def test_object_string_hexadecimal_value
    assert UJSON.parse('{"hexadecimal value": "\u1234 \u5678 \u90AB\uCDEF\uabcd\uef01\u1111"}'), 'Error processing a string with hexadecimal values'
  end
  def test_object_integer_value
    object = UJSON.parse('{"integer":12345678}')
    assert object, 'Error processing an object with integer value'
    assert_equal '12345678', object["integer"], 'Wrong value parsed'
  end
  def test_object_decimal_value
    assert UJSON.parse('{"decimal":-1234.5678}'), 'Error processing an object with a decimal value'
  end
  def test_object_e_format_value
    assert UJSON.parse('{"e": 1e-3}'), 'Error processing an object with a value in \'e\' format'
  end
  def test_object_E_format_value
    assert UJSON.parse('{"E": -2E+3}'), 'Error processing an object with a value in \'E\' format'
  end
  def test_object_true_value
    assert UJSON.parse('{"true": true}'), 'Error processing an object with a true value'
  end
  def test_object_false_value
    assert UJSON.parse('{"false": false}'), 'Error processing an object with a false value'
  end
  def test_object_null_value
    assert UJSON.parse('{"null": null}'), 'Error processing an object with a null value'
  end
  def test_object_object_value
    assert UJSON.parse('{"object": {"hola":"yo"}}'), 'Error processing an object with an object value'
  end
  def test_object_array_value
    assert UJSON.parse('{"array": [1, 2, "hola"]}'), 'Error processing an object with an array value'
  end
  def test_object_several_pairs
    assert UJSON.parse('{"first":"first", "second":2, "third":null, "fourth":[1, 2]}'), 'Error processing an object with several pairs'
  end
  def test_object_extra_value_after_close
    assert_raises(FormatError,
      "Should fail when extra content appears after the object is closed") do
      UJSON.parse('{"hola" : true} "extra text that should make this fail"')
    end
  end
  def test_numbers_cannot_have_leading_zeros
    assert_raises(FormatError,
    "Should fail when a number with leading zeros is used") do
      UJSON.parse('{"wrong number": 012}')
    end
  end
  def test_unclosed_object
    assert_raises(FormatError,
    "Should fail when it finds an unclosed array") do
      UJSON.parse('{"wrong number": 12')
    end
  end
  def test_object_with_extra_comma
    assert_raises(FormatError,
    "Should fail when there is an unnecessary trailing comma") do
      UJSON.parse('{"first":"first", "second":2, "third":null, "fourth":[1, 2]  , }')
    end
  end
  ### ARRAYS
  def test_empty_array
    assert UJSON.parse('[]'), 'Error processing \'[]\''
  end
  def test_array_string_value
    assert UJSON.parse('["hola"]'), 'Error processing an array with a string value'
  end
  def test_array_integer_value
    assert UJSON.parse('[12345678]'), 'Error processing an array with an integer value'
  end
  def test_array_decimal_value
    assert UJSON.parse('[1234.5678]'), 'Error processing an array with a decimal value'
  end
  def test_array_e_format_value
    assert UJSON.parse('[1.23e45]'), 'Error processing an array with a number in \'e\' format'
  end
  def test_array_E_format_value
    assert UJSON.parse('[-32.1E-76]'), 'Error processing an array with a number in \'E\' format'
  end
  def test_array_true_value
    assert UJSON.parse('[true]'), 'Error processing an array with a true value'
  end
  def test_array_false_value
    assert UJSON.parse('[false]'), 'Error processing an array with a false value'
  end
  def test_array_null_value
    assert UJSON.parse('[null]'), 'Error processing an array with a null value'
  end
  def test_array_object_value
    assert UJSON.parse('[{"hola": 1}]'), 'Error processing an array with an object value'
  end
  def test_array_array_value
    assert UJSON.parse('[[1]]'), 'Error processing an array with an array value'
  end
  def test_array_several_values
    assert UJSON.parse('[23e0, "two", 3, false]'), 'Error processing an array with several values'
  end
  def test_unclosed_array
    assert_raises(FormatError,
    "Should fail when it finds an unclosed array") do
      UJSON.parse('["Unclosed array"')
    end
  end
  def test_array_with_extra_comma
    assert_raises(FormatError,
    "Should fail when there is an unnecessary trailing comma") do
      UJSON.parse('["extra comma",]')
    end
  end
  ### EXTRAS
  def test_pass1
    file = File.join(File.dirname(__FILE__), 'fixtures_original/pass1.json')
    assert_raises(FormatError,
    "Should pass when processing file `pass1.json`") do
      UJSON.parse(file)
    end
  end
end

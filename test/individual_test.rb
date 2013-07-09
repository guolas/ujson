require 'minitest/autorun'
require 'ujson.rb'

class UJSONTest < MiniTest::Test

  def test_getting_member_with_numeric_value_1
    file = File.new('test/fixtures/member_number_1.json')
    parser = Parser.new(file)
    member = parser.parse_object(file.each_char)
    assert_equal "hola", member.keys[0], 'It should have only one key with name "hola"'
    assert_equal "-13.303e+3", member["hola"], 'The value stored in "hola" should be "-13.303e+3"'
  end

  def test_getting_member_with_numeric_value_2
    file = File.new('test/fixtures/member_number_2.json')
    parser = Parser.new(file)
    member = parser.parse_object(file.each_char)
    assert_equal "hola", member.keys[0], 'It should have only one key with name "hola"'
    assert_equal "1.9e-3", member["hola"], 'The value stored in "hola" is not correct'
  end

  def test_getting_member_with_string_value
    file = File.new('test/fixtures/member_string.json')
    parser = Parser.new(file)
    member = parser.parse_object(file.each_char)
    assert_equal "hola", member.keys[0], 'It should have only one key with name "hola"'
    assert_equal "yoyo", member["hola"], 'The value stored in "hola" is not correct'
  end

  def test_getting_member_with_true_value
    file = File.new('test/fixtures/member_true.json')
    parser = Parser.new(file)
    member = parser.parse_object(file.each_char)
    assert_equal "hola", member.keys[0], 'It should have only one key with name "hola"'
    assert_equal "true", member["hola"], 'The value stored in "hola" is not correct'
  end

  def test_getting_member_with_false_value
    file = File.new('test/fixtures/member_false.json')
    parser = Parser.new(file)
    member = parser.parse_object(file.each_char)
    assert_equal "hola", member.keys[0], 'It should have only one key with name "hola"'
    assert_equal "false", member["hola"], 'The value stored in "hola" is not correct'
  end

  def test_getting_member_with_null_value
    file = File.new('test/fixtures/member_null.json')
    parser = Parser.new(file)
    member = parser.parse_object(file.each_char)
    assert_equal "hola", member.keys[0], 'It should have only one key with name "hola"'
    assert_equal "null", member["hola"], 'The value stored in "hola" is not correct'
  end

  def getting_member_with_array_value
    file = File.new('test/fixtures/member_array.json')
    parser = Parser.new(file)
    member = parser.parse_object(file.each_char)
    assert_equal "hola", member.keys[0], 'It should have only one key with name "hola"'
    assert_equal 5, member["hola"].size, 'The size of the array stored in "hola" should be 5' 
  end

end

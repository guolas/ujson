require 'minitest/autorun'
require 'ujson.rb'

class UJSONTest < MiniTest::Test

  def test_getting_member_with_numeric_value_1
    file = File.new('test/fixtures/member_number_1.json')
    parser = Parser.new(file)
    member = parser.parse
    assert_equal Hash, member.class, 'It should return a Hash'
    assert_equal "hola", member.keys[0], 'It should have only one key with name "hola"'
    assert_equal "-13.303e+3", member["hola"], 'The value stored in "hola" should be "-13.303e+3"'
  end

  def test_getting_member_with_numeric_value_2
    file = File.new('test/fixtures/member_number_2.json')
    parser = Parser.new(file)
    member = parser.parse
    assert_equal Hash, member.class, 'It should return a Hash'
    assert_equal "hola", member.keys[0], 'It should have only one key with name "hola"'
    assert_equal "1.9e-3", member["hola"], 'The value stored in "hola" is not correct'
  end

  def test_getting_member_with_string_value
    file = File.new('test/fixtures/member_string.json')
    parser = Parser.new(file)
    member = parser.parse
    assert_equal Hash, member.class, 'It should return a Hash'
    assert_equal "hola", member.keys[0], 'It should have only one key with name "hola"'
    assert_equal "yoyo", member["hola"], 'The value stored in "hola" is not correct'
  end

  def test_getting_member_with_true_value
    file = File.new('test/fixtures/member_true.json')
    parser = Parser.new(file)
    member = parser.parse
    assert_equal Hash, member.class, 'It should return a Hash'
    assert_equal "hola", member.keys[0], 'It should have only one key with name "hola"'
    assert_equal "true", member["hola"], 'The value stored in "hola" is not correct'
  end

  def test_getting_member_with_false_value
    file = File.new('test/fixtures/member_false.json')
    parser = Parser.new(file)
    member = parser.parse
    assert_equal Hash, member.class, 'It should return a Hash'
    assert_equal "hola", member.keys[0], 'It should have only one key with name "hola"'
    assert_equal "false", member["hola"], 'The value stored in "hola" is not correct'
  end

  def test_getting_member_with_null_value
    file = File.new('test/fixtures/member_null.json')
    parser = Parser.new(file)
    member = parser.parse
    assert_equal Hash, member.class, 'It should return a Hash'
    assert_equal "hola", member.keys[0], 'It should have only one key with name "hola"'
    assert_equal "null", member["hola"], 'The value stored in "hola" is not correct'
  end

  def test_getting_member_with_object_value_1
    file = File.new('test/fixtures/member_object_1.json')
    parser = Parser.new(file)
    member = parser.parse
    assert_equal Hash, member.class, 'It should return a Hash'
    assert_equal "hola", member.keys[0], 'It should have only one key with name "hola"'
    assert_equal Hash, member["hola"].class, 'It should contain a Hash' 
  end

  def test_getting_member_with_object_value_2
    file = File.new('test/fixtures/member_object_2.json')
    parser = Parser.new(file)
    member = parser.parse
    assert_equal Hash, member.class, 'It should return a Hash'
    assert_equal "hola", member.keys[0], 'It should have a first key with name "hola"'
    assert_equal "adios", member.keys[1], 'It should have a second key with name "adios"'
    assert_equal Hash, member["hola"].class, 'It should contain a Hash'
  end

  def test_getting_array_1
    file = File.new('test/fixtures/array_1.json')
    parser = Parser.new(file)
    array = parser.parse
    assert_equal Array, array.class, 'It should return an Array'
    assert_equal 2, array.size, 'It should have two elements'
    assert_equal Hash, array[0].class, 'First element of the array should be a Hash'
    assert_equal Hash, array[1].class, 'Second element of the array should be a Hash'
  end

  def test_getting_array_2
    file = File.new('test/fixtures/array_2.json')
    parser = Parser.new(file)
    array = parser.parse
    assert_equal Array, array.class, 'It should return an Array'
    assert_equal 2, array.size, 'It should have two elements'
    assert_equal Hash, array[0].class, 'First element of the array should be a Hash'
    assert_equal Hash, array[1].class, 'Second element of the array should be a Hash'
  end

  def test_getting_member_with_array_value
    file = File.new('test/fixtures/member_array.json')
    parser = Parser.new(file)
    member = parser.parse
    assert_equal Hash, member.class, 'It should return a Hash'
    assert_equal "hola", member.keys[0], 'It should have only one key with name "hola"'
    assert_equal 5, member["hola"].size, 'The size of the array stored in "hola" should be 5' 
  end


end

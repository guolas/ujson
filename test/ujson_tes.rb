require 'minitest/autorun'
require 'ujson.rb'
require 'json'

class UJSONTest < MiniTest::Test

  def setup
    object = File.join(File.dirname(__FILE__), 'fixtures/object.json')
    @parsed_json = UJSON.parse(object)
  end

  def test_should_generate_a_hash
    assert_equal Hash, @parsed_json.class, 'It should generate a Hash object'
  end

  def test_first_level_contains_one_key_named_Image
    assert_equal 1, @parsed_json.keys.size, 'First level should have only one key'
    assert_equal "Image", @parsed_json.keys[0], 'First key should be named "Image"'
  end

  def test_second_level_key_Thumbnail_should_be_a_hash_with_three_keys
    assert_equal 3, @parsed_json["Image"]["Thumbnail"].keys.size, 'Thumbnail Hash should have three keys'
  end

  def test_getting_member_with_numeric_value_1
    file = File.new('test/fixtures/member_number.json')
    parser = Parser.new(file)
    member = parser.parse_object(file.each_char)
    assert_equal "hola", member.keys[0], 'It should have only one key with name "hola"'
    assert_equal "-13.303e+3", member["hola"], 'The value stored in "hola" is not correct'
  end
end

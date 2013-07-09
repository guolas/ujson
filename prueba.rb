load 'lib/ujson.rb'

file = File.new('test/fixtures/number_member.json')

parser = Parser.new(file)

parser.parse_object(file.each_char)

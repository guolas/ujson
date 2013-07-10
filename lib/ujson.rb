class UJSON
  class << self
    def parse(input)
      Parser.new(input).parse
    end
  end
end

class Parser
  def initialize(input)
    @raw_json = input
  end

  def parse
      input_enum = @raw_json.each_char
      loop do
        current_char = input_enum.next
        if current_char.eql? '{'
          object = parse_object(input_enum)
        end
        raise StopIteration
      end
  end

  def parse_object(input_enum)
    members = {}
    string = nil
    value = nil
    name_separator = nil
    loop do
      current_char = input_enum.next
      if %r{\S}.match(current_char)
        if !string
          if current_char.eql? '"'
            string = parse_string(input_enum)
          elsif current_char.eql? ',' && members.size == 0
            raise FormatError
          end
        elsif !name_separator
          if %r{\S}.match(current_char)
            value = parse_value(input_enum)
            members[string] = value
            string = nil
            value = nil
          end
        else
          raise FormatError unless current_char.eql? ':'
          name_separator = current_char
        end
      end
      raise StopIteration if current_char.eql? '}'
    end

    return members
  end

  def parse_value(input_enum)
    value = nil
    loop do
      current_char = input_enum.next
      if %r{\S}.match(current_char)
        if current_char.eql? '"'
          value = parse_string(input_enum)
        elsif %r{\d}.match(current_char) || current_char.eql?('-')
          value = parse_number(current_char, input_enum)
        elsif current_char.eql? '{'
          value = parse_object(input_enum)
        elsif current_char.eql? '['
          value = parse_array(input_enum)
        elsif current_char.eql? 't'
          value = parse_literal(current_char, input_enum, 'true')
        elsif current_char.eql? 'f'
          value = parse_literal(current_char, input_enum, 'false')
        elsif current_char.eql? 'n'
          value = parse_literal(current_char, input_enum, 'null')
        elsif current_char.eql? ','
          raise FormatError unless value
          raise StopIteration
        end
      end
    end
    return value
  end

  def parse_string(input_enum)
    string = ""
    
    not_escaped = true

    loop do
      current_char = input_enum.next
      raise StopIteration if not_escaped && current_char.eql?('"')
      string << current_char
      if current_char.eql? '\\'
        not_escaped = false
      end
    end
    return string
  end

  def parse_number(first_element, input_enum)
    number = first_element 
    
    int = %r{\d}.match(first_element)
    frac = false
    exp = false

    loop do
      current_char = input_enum.next
      if !int
        raise FormatError if %r{\D}.match(current_char)
        number << current_char
        int = true
      else
        if frac
          if %r{\d}.match(current_char)
            number << current_char
          elsif current_char.casecmp('e') == 0
            number << current_char
            current_char = input_enum.next
            if %r{[-\+]}.match(current_char)
              number << current_char
              current_char = input_enum.next
            end
            raise FormatError if %r{\D}.match(current_char)
            number << current_char
            exp = true
          else
            raise StopIteration
          end
        elsif exp
          raise StopIteration if %r{\D}.match(current_char)
          number << current_char
        elsif %r{\d}.match(current_char)
          number << current_char
        elsif current_char.eql? '.'
          number << current_char
          current_char = input_enum.next
          raise FormatError if %r{\D}.match(current_char)
          number << current_char
          frac = true
        end
      end
    end
    return number
  end

  def parse_array(input_enum)
    print "\nProcessing Array\n"
    array = []
    value = parse_value(input_enum)
    print "\nRecovered value >", value, "<\n"
    array << value
    loop do

      current_char = input_enum.next
      print current_char
      
      raise StopIteration if current_char.eql? ']'

      if %r{\S}.match(current_char)
        if current_char.eql? ','
          raise FormatError if array.size == 0
        else
          print "\nProcessing A value\n"
          value = parse_value(input_enum) 
          print "\n of value >", value, "<\n"
          array << value
        end
      end
    end
    print "\nReturning array >", array, "<\n"
    return array
  end

  def parse_literal(first_element, input_enum, literal)
    value = first_element
    template = literal.each_char
    template.next
    loop do
      current_char = input_enum.next
      current_template = template.next
      raise FormatError unless current_char.eql? current_template
      value << current_char
    end

    return value
  end
end

class FormatError < StandardError
end

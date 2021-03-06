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
    json = nil
    loop do
      current_char = input_enum.peek
      if %r{\S}.match(current_char)
        if json.nil?
          if current_char.eql? '{'
            json = parse_object(input_enum)
          elsif current_char.eql? '['
            json = parse_array(input_enum)
          else
            raise FormatError
          end
        else
          raise FormatError
        end
      else
        input_enum.next
      end
    end
    return json 
  end

  def parse_object(input_enum)
    object = {}
    string = nil
    value = nil
    current_char = input_enum.next
    raise FormatError if !current_char.eql? '{'
    waiting_for_string = true
    waiting_for_value = false
    waiting_for_other_pair = false
    loop do
      current_char = input_enum.peek
      if %r{\S}.match(current_char)
        if waiting_for_string
          if current_char.eql? '}'
            raise FormatError if waiting_for_other_pair
            raise StopIteration
          elsif current_char.eql? '"'
            string = parse_string(input_enum)
            waiting_for_string = false
          elsif current_char.eql? ','
            raise FormatError if object.size == 0
            waiting_for_other_pair = true
            input_enum.next
          else
            raise FormatError
          end
        elsif waiting_for_value
          waiting_for_other_pair = false
          value = parse_value(input_enum)
          waiting_for_string = true
          waiting_for_value = false
          object[string] = value
        else
          raise FormatError unless current_char.eql? ':'
          waiting_for_value = true
          input_enum.next
        end
      else
        input_enum.next
      end
    end
    unless current_char.eql? '}'
      raise FormatError
    end
    input_enum.next

    return object
  end

  def parse_array(input_enum)
    array = []
    output_options = {}
    current_char = input_enum.next
    raise FormatError if !current_char.eql? '['

    waiting_for_other_element = false

    loop do
      current_char = input_enum.peek
      if %r{\S}.match(current_char)
        if current_char.eql? ']'
          raise FormatError if waiting_for_other_element
          raise StopIteration
        elsif current_char.eql? ','
          raise FormatError if array.size == 0
          waiting_for_other_element = true
          input_enum.next
        else
          waiting_for_other_element = false
          value = parse_value(input_enum)
          array << value
        end
      else
        input_enum.next
      end
    end

    unless current_char.eql? ']'
      raise FormatError
    end
    input_enum.next

    return array
  end

  def parse_value(input_enum)
    value = nil
    current_char = ''
    loop do
      current_char = input_enum.peek
      if %r{\S}.match(current_char)
        if current_char.eql? '"'
          value = parse_string(input_enum)
        elsif %r{\d}.match(current_char) || current_char.eql?('-')
          value = parse_number(input_enum)
        elsif current_char.eql? '{'
          value = parse_object(input_enum)
        elsif current_char.eql? '['
          value = parse_array(input_enum)
        elsif current_char.eql? 't'
          value = parse_literal(input_enum, 'true')
        elsif current_char.eql? 'f'
          value = parse_literal(input_enum, 'false')
        elsif current_char.eql? 'n'
          value = parse_literal(input_enum, 'null')
        else
          raise FormatError unless value
        end
        raise StopIteration
      else
        raise FormatError
      end
    end
    return value
  end

  def parse_string(input_enum)
    escape_chars = ['"', '\\', '/', 'b', 'f', 'n', 'r', 't', 'u']
    string = ''
    escape = false

    raise FormatError unless input_enum.next.eql? '"'
    loop do
      current_char = input_enum.peek
      if escape
        if escape_chars.include? current_char
          string << current_char
          if current_char.eql? 'u'
            hexadecimal_digits = ''
            input_enum.next
            for ii in 1..4
              if ii == 4
                hexadecimal_digit = input_enum.peek
                current_char = hexadecimal_digit
              else
                hexadecimal_digit = input_enum.next
              end
              if %r{[\da-fA-F]}.match(hexadecimal_digit)
                string << hexadecimal_digit
              else
                raise FormatError
              end 
            end
          end
          escape = false
        else
          raise FormatError
        end
      else
        if current_char.eql? '\\'
          string << current_char
          escape = true
        elsif current_char.eql? '"'
          input_enum.next
          raise StopIteration
        elsif %r{\p{Cc}}.match(current_char)
          puts "[string] current_char=" + current_char
          raise FormatError
        else
          string << current_char
        end
      end
      input_enum.next
    end
    return string
  end

  def parse_number(input_enum)
    number = ''
    decimal_point_already_found = false

    current_char = input_enum.next
    if %r{[\d-]}.match(current_char)
      number << current_char
      if current_char.eql? '0'
        if input_enum.peek.eql? '.'
          decimal_point_already_found = true
          number << current_char
          input_enum.next
        elsif %r{[\s,\}\]]}.match(input_enum.peek)
          raise StopIteration
        else
          raise FormatError
        end
      end
    else
      raise FormatError
    end

    loop do
      current_char = input_enum.peek
      if current_char.eql? '.'
        raise FormatError if decimal_point_already_found
        decimal_point_already_found = true
        number << current_char
      elsif %r{\d}.match(current_char)
        number << current_char
      elsif %r{[eE]}.match(current_char)
        number << current_char
        input_enum.next
        current_char = input_enum.peek
        if ['+', '-'].include? current_char
          number << current_char
        elsif %r{\d}.match(current_char)
          number << current_char
        else
          raise FormatError
        end
      elsif %r{[\s,\}\]]}.match(current_char)
        raise StopIteration
      else
        raise FormatError
      end
      input_enum.next
    end
    return number
  end

  def parse_literal(input_enum, literal)
    value = ''
    template = literal.each_char
    current_char = ''
    loop do
      current_template = template.next
      current_char = input_enum.next
      raise FormatError unless current_char.eql? current_template
      value << current_char
    end
    return value
  end

  def print_enum(input_enum)
    loop do
      print input_enum.next
    end
    print "\n"
  end
end

class FormatError < StandardError
end

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
    object = nil
    loop do
      current_char = input_enum.next
      if %r{\S}.match(current_char)
        if current_char.eql? '{'
          object = parse_object(input_enum)
        elsif current_char.eql? '['
          object = parse_array(input_enum)
        else
          raise FormatError
        end
        raise StopIteration
      end
    end
    return object
  end

  def parse_object(input_enum)
    object = {}
    string = nil
    value = nil
    output_options = {}
    current_char = ''

    waiting_for_string = true

    current_char = input_enum.next
    loop do
      if %r{\S}.match(current_char)
        if waiting_for_string
          if current_char.eql? '}'
            puts "[parse_object] (2) object=" + object.to_s + ";"
            raise StopIteration
          elsif current_char.eql? '"'
            string = parse_string(input_enum, :first_char => current_char)
            puts "[parse_object] string=" + string + ";"
            waiting_for_string = false
          elsif current_char.eql? ','
            raise FormatError if object.size == 0
          else
            puts "[parse_object] current_char="+current_char+";"
            raise FormatError
          end
        else
          if current_char.eql? ':'
            value, output_options = parse_value(input_enum)
            waiting_for_string = true

            object[string] = value

            puts "[parse_object] object=" + object.to_s + ";"
            puts "[parse_object] output_options=" + output_options.to_s + ";"
          else
            raise FormatError
          end
        end
      end

      last_char = output_options.fetch(:last_char, '')
      puts "[parse_object] last_char=" + last_char + ";"
      if last_char.eql? ''
        current_char = input_enum.next
        output_options = {}
      else
        current_char = last_char
        output_options = {}
      end
    end

    return object
  end

  def parse_array(input_enum)
    array = []
    output_options = {}

    puts "vvvvvvvv"    
    value, outoput_options = parse_value(input_enum)
    puts "[parse_array] Value = " + value.to_s
    array << value

    last_char = output_options.fetch(:last_char, '')
    puts "[parse_array] last_char=" + last_char + ";"
    if last_char.eql? ''
      current_char = input_enum.next
    else
      current_char = last_char
    end

    puts "[parse_array] current_char=" + current_char + ";"
    loop do
      if %r{\S}.match(current_char)
        if current_char.eql? ']'
          raise StopIteration
        elsif current_char.eql? ','
          value, output_options = parse_value(input_enum)
          puts "[parse_array] Value = " + value.to_s
          array << value
        else
          puts "[parse_array] current_char=" + current_char + ";"
          raise FormatError
        end
      end
      last_char = output_options.fetch(:last_char, '')
      if last_char.eql? ''
        current_char = input_enum.next
        output_options = {}
      else
        current_char = last_char
        output_options = {}
      end
    end

    puts "[parse_array] array =" + array.to_s + ";"
    return array
  end

  def parse_value(input_enum)
    value = nil
    output_options = {}
    loop do
      current_char = input_enum.next
      if %r{\S}.match(current_char)
        if current_char.eql? '"'
          value = parse_string(input_enum, :first_char => current_char)
        elsif %r{\d}.match(current_char) || current_char.eql?('-')
          value, output_options = parse_number(input_enum, current_char)
        elsif current_char.eql? '{'
          value = parse_object(input_enum)
        elsif current_char.eql? '['
          value = parse_array(input_enum)
        elsif current_char.eql? 't'
          value, output_options = parse_literal(input_enum, current_char, 'true')
        elsif current_char.eql? 'f'
          value, output_options = parse_literal(input_enum, current_char, 'false')
        elsif current_char.eql? 'n'
          value, output_options = parse_literal(input_enum, current_char, 'null')
        else
          raise FormatError unless value
        end
        raise StopIteration
      end
    end

    last_char = output_options.fetch(:last_char, '')
    if last_char.eql? ''
      output_options = {}
    else
      output_options = {:last_char => last_char}
    end
    return value, output_options
  end

  def parse_string(input_enum, options ={})
    string = ''

    escape = false
    quotation = false

    first_char = options.fetch(:first_char, ' ')
    if %r{\S}.match(first_char)
      raise FormatError unless first_char.eql? '"'
      quotation = true
    end

    loop do
      current_char = input_enum.next
      if quotation
        if escape
          string << curent_char
          escape = false
        else
          if current_char.eql? '\\'
            string << current_char
            escape = true
          elsif current_char.eql? '"'
            raise StopIteration
          else
            string << current_char
          end
        end
      else
        if %r{\S}.match(current_char)
          if current_char.eql? '"'
            quotation = true
          else
            raise FormatError
          end
        end
      end
    end
    return string
  end

  def parse_number(input_enum, first_element)
    current_char = ''
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
    return number, :last_char => current_char
  end

  def parse_literal(input_enum, first_element, literal)
    value = first_element
    template = literal.each_char
    template.next
    loop do
      current_char = input_enum.next
      current_template = template.next
      raise FormatError unless current_char.eql? current_template
      value << current_char
    end

    return value, {}
  end
end

class FormatError < StandardError
end

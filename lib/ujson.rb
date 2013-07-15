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
            raise StopIteration
          elsif current_char.eql? '"'
            string = parse_string(input_enum, :first_char => current_char)
            waiting_for_string = false
          elsif current_char.eql? ','
            raise FormatError if object.size == 0
          else
            raise FormatError
          end
        else
          if current_char.eql? ':'
            value, output_options = parse_value(input_enum)
            waiting_for_string = true

            object[string] = value

          else
            raise FormatError
          end
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

    return object
  end

  def parse_array(input_enum)
    array = []
    output_options = {}

    value, outoput_options = parse_value(input_enum)
    array << value

    last_char = output_options.fetch(:last_char, '')
    if last_char.eql? ''
      current_char = input_enum.next
    else
      current_char = last_char
    end

    loop do
      if %r{\S}.match(current_char)
        if current_char.eql? ']'
          raise StopIteration
        elsif current_char.eql? ','
          value, output_options = parse_value(input_enum)
          array << value
        else
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
          value, output_options = parse_number(input_enum, :first_char => current_char)
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

  def parse_number(input_enum, options = {})
    number = ''

    current_char = options.fetch(:first_char, ' ')

    decimal_point_already_found = false

    loop do
      if %r{\S}.match(current_char)
        if current_char.eql? '-'
          number << current_char
          current_char = input_enum.next
        end
        if %r{\d}.match(current_char)
          number << current_char
          if current_char.eql? '0'
            current_char = input_enum.next
            if current_char.eql? '.'
              decimal_point_already_found = true
              number << current_char
            else
              raise FormatError
            end
          end
          raise StopIteration
        else
          raise FormatError
        end
      end
      current_char = input_enum.next
    end

    loop do
      current_char = input_enum.next
      if current_char.eql? '.'
        raise FormatError if decimal_point_already_found
        decimal_point_already_found = true
        number << current_char
      elsif %r{\d}.match(current_char)
        number << current_char
      elsif %r{[eE]}.match(current_char)
        number << current_char
        current_char = input_enum.next
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
    end
    return number, :last_char => current_char
  end

  def parse_literal(input_enum, first_element, literal)
    value = first_element
    current_char = ''
    template = literal.each_char
    template.next
    loop do
      current_char = input_enum.next
      current_template = template.next
      raise FormatError unless current_char.eql? current_template
      value << current_char
    end

    output_options = {:last_char => current_char}
    return value, output_options
  end
end

class FormatError < StandardError
end

require 'active_support/core_ext/object/blank'
require 'ox'

class EasySax::OxParser < ::Ox::Sax
  attr_reader :io,
              :target_element,
              :callback,
              :ignorable_elements,
              :array_elements,
              :element_stack

  def initialize(io)
    @io = io
  end

  def parse_each(target_element, ignore: [], arrays: [], &block)
    @target_element = target_element.to_s
    @ignorable_elements = validate_array(:ignore, ignore)
    @array_elements = validate_array(:arrays, arrays)
    @element_stack = []
    @callback = block
    Ox.sax_parse(self, @io)
  end

  def start_element(name)
    return if ignorable_elements.include?(name.to_s)

    parent = element_stack.last
    element = EasySax::SimpleElement.new(name.to_s, {})

    if parent.nil?
      element_stack << element
    else
      add_child(parent, element)
    end
  end

  def text(value)
    return unless element_stack.last

    element_stack.last.text ||= ''
    element_stack.last.text << value.strip
  end

  def attr(name, value)
    element_stack.last.attrs[name.to_s] = value
  end

  def cdata(string)
    text(string)
  end

  def end_element(name)
    return if ignorable_elements.include?(name.to_s)

    element = element_stack.pop
    callback.call element, element_stack.first if name.to_s == target_element
  end

  def error(string)
    raise EasySax::ParseError.new(string)
  end

  private

  def validate_array(field, array)
    if array.nil?
      []
    elsif array.is_a?(Array)
      array.map(&:to_s)
    else
      raise ArgumentError, ('%s must be an Array' % field)
    end
  end

  def add_child(parent, element)
    if array_elements.include?(element.name)
      parent[element.name] = []
      element_stack << parent[element.name]
    else
      if parent.is_a?(Array)
        parent << element
      elsif element.name != target_element
        parent[element.name] = element
      end

      element_stack << element
    end
  end
end

require 'active_support/core_ext/object/blank'
require 'nokogiri'

class EasySax::Parser < Nokogiri::XML::SAX::Document
  attr_reader :io,
    :target_element,
    :callback,
    :ignorable_elements,
    :array_elements,
    :element_stack,
    :element_text

  def initialize(io)
    @io = io
  end

  def parse_each(target_element, ignore: [], arrays: [], &block)
    validate_array(:arrays, arrays)
    @target_element = target_element.to_s
    @ignorable_elements = validate_array(:ignore, ignore)
    @array_elements = validate_array(:arrays, arrays)
    @element_stack = []
    @callback = block
    Nokogiri::XML::SAX::Parser.new(self).parse(io)
  end

  def start_element(name, attrs = [])
    return if ignorable_elements.include?(name)
    @element_text = ''
    parent = element_stack.last

    if parent.nil?
      element_stack << EasySax::SimpleElement.new(name, attrs.to_h)
    else
      add_child(parent, name, attrs)
    end
  end

  def characters(string)
    @element_text << string if element_text
  end

  def cdata_block(string)
    characters(string)
  end

  def end_element(name)
    return if ignorable_elements.include?(name)

    element = element_stack.pop
    return if element.kind_of?(Array)

    element.text = element_text.strip if element_text.present?
    callback.call element, element_stack.first if name == target_element
  end

  def error(string)
    raise EasySax::ParseError.new(string)
  end

  private

  def validate_array(field, array)
    if array.nil?
      []
    elsif array.kind_of?(Array)
      array.map { |element| element.to_s }
    else
      raise ArgumentError, ("%s must be an Array" % field)
    end
  end

  def add_child(parent, name, attrs)
    if array_elements.include?(name)
      parent[name] = []
      element_stack << parent[name]
    else
      element = EasySax::SimpleElement.new(name, attrs.to_h)

      if parent.kind_of?(Array)
        parent << element
      elsif name != target_element
        parent[name] = element
      end

      element_stack << element
    end
  end
end

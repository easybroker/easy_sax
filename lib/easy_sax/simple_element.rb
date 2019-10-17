require 'active_support/core_ext/hash/indifferent_access'

class EasySax::SimpleElement
  attr_accessor :name, :attrs, :elements, :text

  def initialize(name, attrs)
    @name = name
    @attrs = HashWithIndifferentAccess.new(attrs || {})
    @elements = HashWithIndifferentAccess.new
  end

  def [](key)
    elements[key]
  end

  def []=(key, value)
    elements[key] = value
  end

  def text_for(key)
    elements[key]&.text
  end

  def to_h
    {}.tap do |hash|
      hash[:attrs] = attrs unless attrs.empty?
      hash[:elements] = elements unless elements.empty?
      hash[:text] = text if text
    end
  end

  alias_method :inspect, :to_h
  alias_method :to_s, :to_h
end

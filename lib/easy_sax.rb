require 'easy_sax/version'
require 'easy_sax/parse_error'
require 'easy_sax/simple_element'
require 'easy_sax/parser'

# A simple SAX parser that enables parsing of large files without
# the messy syntax of typical SAX parsers. Currently depends on
# Nokogiri.
#
# Basic Usage:
# EasySax.parser(io).parse_each(target_element, ignore:, array:)
#   target_element: is the element you want to parse
#   ignore: are elements that will be ignored and not parsed
#   arrays: are the elements that should parsed into arrays
#
# You should use a block which returns the parsed target element
# and it's ancestors if it has one.
module EasySax
  def self.parser(io)
    EasySax::Parser.new(io)
  end
end

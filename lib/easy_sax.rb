require 'easy_sax/version'
require 'easy_sax/parse_error'
require 'easy_sax/simple_element'
require 'easy_sax/parser'
require 'easy_sax/ox_parser'

# Simple SAX parsers that enable parsing of large files without
# the messy syntax of typical SAX parsers.
# You should use a block which returns the parsed target element
# and it's ancestors if it has one.
module EasySax
  def self.parser(io)
    # Currently depends on Nokogiri.
    #
    # Basic Usage:
    # EasySax.parser(io).parse_each(target_element, ignore:, array:)
    #   target_element: is the element you want to parse
    #   ignore: are elements that will be ignored and not parsed
    #   arrays: are the elements that should parsed into arrays
    EasySax::Parser.new(io)
  end

  def self.ox_parser(io)
    # Currently depends on ox.
    #
    # Basic Usage:
    # EasySax.oxparser(io).parse_each(target_element, ignore:, array:)
    #   target_element: is the element you want to parse
    #   ignore: are elements that will be ignored and not parsed
    #   arrays: are the elements that should parsed into arrays
    EasySax::OxParser.new(io)
  end
end

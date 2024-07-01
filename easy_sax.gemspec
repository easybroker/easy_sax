# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'easy_sax/version'

Gem::Specification.new do |spec|
  spec.name          = "easy_sax"
  spec.version       = EasySax::VERSION
  spec.authors       = ["Eric Northam"]
  spec.email         = ["eric@easybroker.com"]

  spec.summary       = "A simple SAX parser that enables parsing of large files without the messy syntax of typical SAX parsers."
  spec.description   = "A simple SAX parser that enables parsing of large files without the messy syntax of typical SAX parsers. Currently depends on Nokogiri."
  spec.homepage      = "https://github.com/easybroker/easy_sax"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "nokogiri", "~> 1.16.5"
  spec.add_dependency "activesupport", "~> 7.0.8"

  spec.add_development_dependency "bundler", "~> 2.3.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "pry"
end

# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'benchmark'
require 'memory_profiler'
require 'easy_sax'

TEST_XML = <<~XML
  <agencies>
    <agency id="1">
      <name>Foo</name>
      <phone>12345678</phone>
      <properties>
        <property id="2">
          <title>Test 2</title>
          <images>
            <image url="http://test.com/1.jpg"/>
            <image url="http://test.com/2.jpg"/>
          </images>
        </property>
      </properties>
    </agency>
    <agency id="2">
      <name>Bar</name>
      <properties>
        <property id="3">
          <title>Test 3</title>
          <images>
            <image url="http://test.com/3.jpg"/>
            <image url="http://test.com/4.jpg"/>
          </images>
        </property>
      </properties>
    </agency>
  </agencies>
XML

def create_parser(parser_class)
  parser_class.new(StringIO.new(TEST_XML))
end

def parse_with_parser(parser)
  agencies = []
  parser.parse_each(:agency, ignore: %w[agencies], arrays: %w[properties images]) do |agency|
    agencies << agency
  end
end

puts 'Time Benchmark:'
Benchmark.bm(10) do |x|
  x.report('Nokogiri:') { parse_with_parser(create_parser(EasySax::Parser)) }
  x.report('Ox:') { parse_with_parser(create_parser(EasySax::OxParser)) }
end

puts "\nMemory Benchmark:"
[[:nokogiri, EasySax::Parser], [:ox, EasySax::OxParser]].each do |name, parser_class|
  report = MemoryProfiler.report do
    parser = create_parser(parser_class)
    parse_with_parser(parser)
  end

  puts "\n#{name.capitalize} Parser:"
  puts "Total allocated memory: #{report.total_allocated_memsize / 1024.0} KB"
  puts "Total retained memory:  #{report.total_retained_memsize / 1024.0} KB"
  puts "Total objects allocated: #{report.total_allocated}"
  puts "Total objects retained:  #{report.total_retained}"
  # Uncomment the line below for more detailed output:
  # report.pretty_print(scale_bytes: true)
end

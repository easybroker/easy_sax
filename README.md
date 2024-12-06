# EasySax

EasySax allows you to easily parse large files without the messy syntax needed
for working with most Sax parsers. It was inspired after attempting to use
[SaxMachine](https://github.com/pauldix/sax-machine) to parse a 500mb XML file
that resulted in a huge spike to 2gbs of memory inside a Rails app. EasySax is
very lightweight and only stores the element currently being used in memory. It
also allows you to access parent elements without storing the whole parent tree
in memory. Testing with the same file above, the memory stayed constant and it
processed the file much faster. EasySax is currently used in production at
EasyBroker.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'easy_sax'
```

And then execute:

```shell
bundle
```

Or install it yourself as:

```shell
gem install easy_sax
```

## Usage

Given the following test XML

```xml
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
      <property id="3">
        <title>Test 3</title>
        <images>
          <image url="http://test.com/5.jpg"/>
          <image url="http://test.com/4.jpg"/>
        </images>
      </property>
    </properties>
  </agency>
  <agency id="2">
    <name>Bar</name>
    <properties>
      <property id="4">
        <title>Test 4</title>
        <images>
          <image url="http://test.com/3.jpg"/>
          <image url="http://test.com/4.jpg"/>
        </images>
      </property>
    </properties>
  </agency>
</agencies>
```

You can parse all the property elements with

```ruby
parser = EasySax.parser(File.open('test.xml'))
parser.parse_each(:property) do |property|
  puts "Property id[#{property.attrs[:id]}] title[#{property[:title].text}]"
end
```

Outputs

```shell
Property id[2] title[Test 2]
Property id[3] title[Test 3]
Property id[4] title[Test 4]
```

You can also use the `text_for` method if you prefer to get text elements.
`property.text_for(:title)` is the same as `property[:title].text` except it
returns nil if the title element doesn't exist.

If you want to print the property image urls you need to let the parser know
that it is an array

```ruby
parser = EasySax.parser(File.open('test.xml'))
parser.parse_each(:property, arrays: ['images']) do |property|
  image_urls = property[:images].map { |image| image.attrs[:url] }
  puts "Property id[#{property.attrs[:id]}] images#{image_urls}"
end
```

Outputs

```shell
Property id[2] images ["http://test.com/1.jpg", "http://test.com/2.jpg"]
Property id[3] images ["http://test.com/4.jpg", "http://test.com/5.jpg"]
Property id[4] images ["http://test.com/3.jpg", "http://test.com/4.jpg"]
```

Now for something really cool. If you want the root ancestor use the second
param in the `parse_each` block

```ruby
parser = EasySax.parser(File.open('test.xml'))
parser.parse_each(:property) do |property, ancestor|
  puts "Property id[#{property.attrs[:id]}] agency id[#{ancestor[:agency].attrs[:id]}]"
end
```

Outputs

```shell
Property id[2] agency id[1]
Property id[3] agency id[1]
Property id[4] agency id[2]
```

Now maybe you're lazy like me and don't care about the `agencies` element and
want the `agency` to be the oldest ancestor.

```ruby
parser = EasySax.parser(File.open('test.xml'))
parser.parse_each(:property, ignore: ['agencies']) do |property, ancestor|
  puts "Property id[#{property.attrs[:id]}] agency id[#{ancestor.attrs[:id]}]"
end
```

Outputs

```shell
Property id[2] agency id[1]
Property id[3] agency id[1]
Property id[4] agency id[2]
```

You can also use `ignore` to speed up the parser by allowing it to know that it
doesn't need to keep track of the those elements.

## Performance improvement(alpha version)

Currently there are two parser methods `EasySax.parser` is currently well
tested in production using parser. There is a new method named `ox_parser` that
is backward compatible with current code and examples listed in this readme.

Behind scenes the improvement is due the replacement of nokogiri for ox.

### Benchmark setup

```text
OS: macOS Sequoia 15.1.1 arm64
Host: MacBook Pro (14-inch, 2021)
Kernel: Darwin 24.1.0
CPU: Apple M1 Pro (8) @ 3.23 GHz
GPU: Apple M1 Pro (14) @ 1.30 GHz [Integrated]
Memory: 32.00 GiB
ruby 3.3.6 (2024-11-05 revision 75015d4c1f) [arm64-darwin24]
```

### Results

```text
Time Benchmark:
                 user     system      total        real
Nokogiri:    0.000114   0.000015   0.000129 (  0.000128)
Ox:          0.000058   0.000002   0.000060 (  0.000062)

Memory Benchmark:

Nokogiri Parser:
Total allocated memory: 22.90625 KB
Total retained memory:  0.0 KB
Total objects allocated: 430
Total objects retained:  0

Ox Parser:
Total allocated memory: 14.984375 KB
Total retained memory:  0.078125 KB
Total objects allocated: 205
Total objects retained:  2
```

### Performance Conclusion

The new ox_parser demonstrates significant performance improvements over the
EasySax parser that relies on Nokogiri. Below is a summary of the key metrics:

1. Execution Time:

   - ox_parser is ~52% faster than EasySax in terms of real execution time.
   - Nokogiri: 0.000128 seconds
   - Ox: 0.000062 seconds

2. Memory Usage:

   - Total allocated memory is reduced by ~35% when using ox_parser.
     Nokogiri: 22.91 KB
     Ox: 14.98 KB

   - Object allocation is reduced by ~52%, making Ox more efficient:
     Nokogiri: 430 objects
     Ox: 205 objects

3. Retained Memory:
   - While Nokogiri retains 0 KB, ox_parser retains a negligible amount of
     0.078 KB due to its design. However, the overall efficiency in memory
     allocation offsets this minor difference.

### Why Switch to ox_parser?

- Speed: The ox_parser is approximately 2x faster, ensuring faster XML parsing
  for applications with high performance needs.
- Efficiency: Reduces memory usage significantly, benefiting applications
  running in constrained environments.
- Backward Compatibility: ox_parser works seamlessly with existing code and
  examples listed in this README.

> [!CAUTION]
> `ox_parser` needs test and monitoring in production environments.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake test` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at [issues](https://github.com/easybroker/easy_sax/issues)

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

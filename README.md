# EasySax

EasySax allows you to easily parse large files without the messy syntax needed for working with most Sax parsers. It was inspired after attempting to use [SaxMachine](https://github.com/pauldix/sax-machine) to parse a 500mb XML file that resulted in a huge spike to 2gbs of memory inside a Rails app. EasySax is very lightweight and only stores the element currently being used in memory. It also allows you to access parent elements without storing the whole parent tree in memory. Testing with the same file above, the memory stayed constant and it processed the file much faster. EasySax is currently used in production at EasyBroker.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'easy_sax'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install easy_sax

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
          <image url="http://test.com/4.jpg"/>
          <image url="http://test.com/5.jpg"/>
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

```
Property id[2] title[Test 2]
Property id[3] title[Test 3]
Property id[4] title[Test 4]
```

You can also use the `text_for` method if you prefer to get text elements. `property.text_for(:title)` is the same as `property[:title].text` except it returns nil if the title element doesn't exist.

If you want to print the property image urls you need to let the parser know that it is an array

```ruby
parser = EasySax.parser(File.open('test.xml'))
parser.parse_each(:property, arrays: ['images']) do |property|
  image_urls = property[:images].map { |image| image.attrs[:url] }
  puts "Property id[#{property.attrs[:id]}] images#{image_urls}"
end
```

Outputs

```
Property id[2] images ["http://test.com/1.jpg", "http://test.com/2.jpg"]
Property id[3] images ["http://test.com/4.jpg", "http://test.com/5.jpg"]
Property id[4] images ["http://test.com/3.jpg", "http://test.com/4.jpg"]
```

Now for something really cool. If you want the root ancestor use the second param in the `parse_each` block

```ruby
parser = EasySax.parser(File.open('test.xml'))
parser.parse_each(:property) do |property, ancestor|
  puts "Property id[#{property.attrs[:id]}] agency id[#{ancestor[:agency].attrs[:id]}]"
end
```

Outputs

```
Property id[2] agency id[1]
Property id[3] agency id[1]
Property id[4] agency id[2]
```

Now maybe you're lazy like me and don't care about the `agencies` element and want the `agency` to be the oldest ancestor.

```ruby
parser = EasySax.parser(File.open('test.xml'))
parser.parse_each(:property, ignore: ['agencies']) do |property, ancestor|
  puts "Property id[#{property.attrs[:id]}] agency id[#{ancestor.attrs[:id]}]"
end
```

Outputs

```
Property id[2] agency id[1]
Property id[3] agency id[1]
Property id[4] agency id[2]
```

You can also use `ignore` to speed up the parser by allowing it to know that it doesn't need to keep track of the those elements.
## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/easybroker/easy_sax.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


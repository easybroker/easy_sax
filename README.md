# EasySax

EasySax allows you to easily parse large files without the messy syntax needed for workign with most Sax parsers. It was inspired after attempting to use [SaxMachine](https://github.com/pauldix/sax-machine) to parse a 500mb which resulted in over 2gbs of memory consumption inside of a Rails app. EasySax is very lightweight and only stores the element currently being used in memory and also allows you to access parent elements without storing the whole parent tree in memory. For the scenario above, memory usage remained at 300mb and went from taking 7 days to parse the file to 1 hour. This also includes time that was used for other actions besides parsing.

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

```ruby
parser = EasySax.parse(File.open('test.xml'))
parser.parse_each(:property).do |property|
  puts property.attrs['id']
  puts property.attrs['']
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/easybroker/easy_sax.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


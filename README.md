# Mmh3

![Ruby](https://github.com/yoshoku/mmh3/workflows/Ruby/badge.svg)
[![Gem Version](https://badge.fury.io/rb/mmh3.svg)](https://badge.fury.io/rb/mmh3)

A pure Ruby implementation of [MurmurHash3](https://en.wikipedia.org/wiki/MurmurHash).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mmh3'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install mmh3

## Usage

```ruby
require 'mmh3'

puts Mmh3.hash32('Hello, world', 10)

# => -172601702
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yoshoku/mmh3.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

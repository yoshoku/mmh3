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
irb(main):001:0> require 'mmh3'
=> true
irb(main):002:0> Mmh3.hash32('Hello, world', seed: 3)
=> 1659891412
irb(main):003:0> Mmh3.hash128('Hello, world', seed: 8)
=> 87198040132278428547135563345531192982
irb(main):004:0> Mmh3.hash32('Hello, world')
=> 1785891924
irb(main):005:0> Mmh3.hash32('Hello, world', seed: 0)
=> 1785891924
irb(main):006:0>
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yoshoku/mmh3.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

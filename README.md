# Mmh3

[![Build Status](https://github.com/yoshoku/mmh3/workflows/build/badge.svg)](https://github.com/yoshoku/mmh3/actions?query=workflow%3Abuild)
[![Coverage Status](https://coveralls.io/repos/github/yoshoku/mmh3/badge.svg?branch=main)](https://coveralls.io/github/yoshoku/mmh3?branch=main)
[![Gem Version](https://badge.fury.io/rb/mmh3.svg)](https://badge.fury.io/rb/mmh3)
[![Documentation](https://img.shields.io/badge/api-reference-blue.svg)](https://rubydoc.info/gems/mmh3)

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

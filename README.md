# Kakasi for Ruby

A Ruby binding for KAKASI implemented with Fiddle/DL/FFI

## Description

This library is a port of Ruby/KAKASI to Ruby >=1.9.

Ruby/KAKASI was an extention library written by GOTO Kentaro for
ancient CRuby, which did not work with Ruby >=1.9 or JRuby,

This implementation uses Fiddle/DL/FFI as a bridge to libkakasi, so it
should work with any ruby that supports Fiddle/DL/FFI module, such as:

- Ruby 1.9.3 (DL)
- Ruby 2.0.0+ (Fiddle)
- Rubinius (Rubinius::FFI)
- JRuby (FFI)

## Installation

Add this line to your application's Gemfile:

    gem 'kakasi'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install kakasi

## Usage

    require 'kakasi'

    Kakasi.kakasi('-w', 'Rubyから案山子を呼び出せます。')
    #=> "Ruby から 案山子 を 呼び出せ ます 。"

## Links

- [KAKASI - Kanji Kana Simple Inverter](http://kakasi.namazu.org/index.html.en)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

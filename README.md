# jkf

jkf is [json-kifu-format][jkf] library for Ruby.

[jkf]: https://github.com/na2hiro/json-kifu-format

## Feature

* KIF, KI2, CSA to JKF
* JKF to KIF, KI2, CSA

## Installation

Add this line to your `Gemfile`:

```ruby
gem 'jkf', git: {{repository URL}}
```

And then execute:

```shell-session
bundle
```

## Usage

```ruby
kif_parser = Jkf::Parser::Kif.new
ki2_parser = Jkf::Parser::Ki2.new
csa_parser = Jkf::Parser::Csa.new
```

```ruby
kif_converter = Jkf::Converter::Kif.new
ki2_converter = Jkf::Converter::Ki2.new
csa_converter = Jkf::Converter::Csa.new
```

```ruby
jkf = kif_parser.parse(kif_str) #=> Hash
jkf = ki2_parser.parse(ki2_str) #=> Hash
jkf = csa_parser.parse(csa_str) #=> Hash
```

```ruby
kif = kif_converter.convert(jkf) #=> String
ki2 = ki2_converter.convert(jkf) #=> String
csa = csa_converter.convert(jkf) #=> String
```

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/gemmaro/ruby-json-kifu-format).

## License

The gem is available as open source under the terms of [the MIT License](http://opensource.org/licenses/MIT).

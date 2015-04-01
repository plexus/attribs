# Attribs

Easy and flexible Ruby value objects.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'attribs'
```

And then execute:

    $ gem install -g


Or install it directly:

    $ gem install attribs

## Usage

``` ruby
class Widget
  include Attribs.new(:color, :size, quantity: 1)
end

w = Widget.new(color: 'blue', size: '10')
w2 = w.with(color: 'red')
puts w2.pp
w.to_h
```

## Shoutout

To [Anima](https://github.com/mbj/anima), which powers most of what
Attribs offers.

## License

&copy; 2014-2015 Arne Brasseur

MIT License (see LICENSE.txt)

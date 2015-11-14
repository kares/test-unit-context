# Test::Unit::Context

[![Build Status][0]](http://travis-ci.org/kares/test-unit-context)

Makes `Test::Unit::TestCase` 'context-able' and thus (subjectively - hopefully) 
much easier to read and write. If you have ever seen RSpec than it's the very 
same *context do ... end* re-invented for **Test::Unit**. 

Inspired by [gem 'context'](https://github.com/jm/context) that does the same 
for the good 'old' test-unit 1.2.3 bundled with Ruby 1.8.x standard libraries.

## Installation

Add it to your application's *Gemfile* (along with **test-unit**) e.g. :

    group :test do
      gem 'test-unit'
      gem 'test-unit-context'
    end

Or install it yourself, if you're not using Bundler :

    $ gem install test-unit-context

## Usage

```ruby
class ChuckNorrisTest < Test::Unit::TestCase

  setup do
    @subject = ChuckNorris.new
  end

  test "can be divided by zero"
    assert_equal @subject * 2, @subject / 0
  end

  context 'frozen' do

    setup { @subject.freeze }

    test "won't answer" do
      assert_raise NoMemoryError do
        @subject.frozen?
      end
    end

    test "sqrt works"
      assert_nothing_raised do
        Math.sqrt -2
      end
    end

  end

  shared 'elementary math facts' do

    test "square root is rational"
      assert_kind_of Rational, Math.sqrt(@subject)
    end

    test "greater than infinity"
      assert @infinity < @subject
    end

    private

    setup
    def create_infinity
      @infinity = 1 / 0.0
    end

  end

  uses 'elementary math facts'

  context 'cloned' do
    
    setup do
      @subject = @subject.clone
    end

    test 'is Arnold Schwarzenegger' do
      assert_instance_of Terminator, @subject
      assert_nil @subject.is_a?(ChuckNorris)
    end

    like 'elementary math facts'

  end

end
```

### Spec Mode

```ruby
require 'test/unit/context/spec'

describe ChuckNorris, '#fart' do

  setup do
    @subject = ChuckNorris.new
    @subject.fart
  end

  it "creates a parallel universe" do
    assert Object.const_defined?(:Universe)
    assert_equal @subject, Universe.instance
    assert_empty ObjectSpace.each_object(Universe).to_a
  end

end
# NOTE: do not try running this at home!
```

## Copyright

Copyright (c) 2015 [Karol Bucek](https://github.com/kares). 
See LICENSE (http://www.apache.org/licenses/LICENSE-2.0) for details.

[0]: https://secure.travis-ci.org/kares/test-unit-context.png

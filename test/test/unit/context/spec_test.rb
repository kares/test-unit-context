require File.expand_path('../../../test_helper', File.dirname(__FILE__))

module Test::Unit::Context
  class SpecTest < Test::Unit::TestCase

    require 'test/unit/context/spec'
    require 'test/unit/context/spec_spec'
    
    def test_sets_up_describe
      assert self.class.respond_to?(:describe)
      assert ::Object.respond_to?(:describe)
    end

    #def test_sets_up_it_alias
      #assert self.class.respond_to? :it
    #end

    test "set-up spec_spec TestCase constants" do
      # describe User42
      assert Object.const_defined?(:User42Test)
      user_42_test = Object.const_get(:User42Test)
      assert_equal Test::Unit::TestCase, user_42_test.superclass
      #assert_equal 'User42', user_42_test.name
      
      # describe 'nested'
      assert user_42_test.const_defined?(:NestedTest)
      user_42_nested_test = user_42_test.const_get(:NestedTest)
      #assert_equal user_42_test, user_42_nested_test.superclass
      assert_equal Test::Unit::TestCase, user_42_nested_test.superclass
      #assert_equal 'nested', user_42_nested_test.name
      
      # describe User42, '#new'
      assert Object.const_defined?(:User42NewTest)
      user_42_new_test = Object.const_get(:User42NewTest)
      assert_equal Test::Unit::TestCase, user_42_new_test.superclass
      #assert_equal 'User42#new', user_42_new_test.name
      
      # describe Foo, 'bar', :baz
      assert Object.const_defined?(:FoobarbazTest)
    end

    test "run spec_spec 'it' tests" do
      at_exit { assert ::User42::SPEC_SAMPLE }
    end
    
  end
end

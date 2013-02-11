module Test::Unit::Context
  module Spec
    
    PREFIX = nil # :nodoc:
    SUFFIX = 'Test'.freeze # :nodoc:
    
    # Spec style Test::Unit::TestCase (sub-classes) :
    # 
    #   describe User do
    #     it "creates a new instance" do
    #       assert_nothing_raised { User.new }
    #     end
    #   end
    # 
    # You need to `require 'test/unit/context/spec'` ( e.g. in test_helper.rb).
    #
    # The generated Test::Unit::TestCase sub-class follows the "Test" suffix 
    # naming convention e.g. `describe User` ends up as `UserTest < TestCase`.
    #
    def describe(*args, &block) 
      name = args.map { |arg| arg.is_a?(Class) ? arg.name : arg }.join
      class_name = Helpers.to_const_name(name.freeze, PREFIX, SUFFIX)
      self_klass = self.is_a?(Class) ? self : self.class # nested describes
      if self_klass.const_defined?(class_name)
        klass = self_klass.const_get(class_name)
        if klass <= Test::Unit::TestCase
          warn "duplicate test-case describe with args #{args.inspect} " << 
                "found at #{caller.first} it is going to be merged with " << 
                "the previous TestCase definition"
        else
          raise "could not create a test-case with args #{args.inspect} " << 
                "as a constant #{class_name} is already defined and is not " << 
                "another TestCase definition"
        end
      else
        # NOTE: context inherits from nesting case but describe should not :
        #is_test_case = ( self_klass <= Test::Unit::TestCase )
        #klass = Class.new is_test_case ? self_klass : Test::Unit::TestCase
        klass = Class.new(Test::Unit::TestCase)
        klass.send(:define_method, :name) { name }
        klass.extend Methods
        self_klass.const_set(class_name, klass)
      end
      klass.class_eval(&block)
      klass
    end
    
    module Methods
      
      # It is an alias for Test::Unit's test method.
      # @see Test::Unit::TestCase#test
      def it(*args, &block); test(*args, &block); end
      
    end
    
  end
end

Object.send :include, Test::Unit::Context::Spec

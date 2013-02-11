require File.expand_path('../../test_helper', File.dirname(__FILE__))

module Test::Unit
  class TestContext < Test::Unit::TestCase
    
    def test_test_without_context
      assert true
    end

    test "another test without a context" do
      assert true
    end
    
    def test_context_aliases
      assert self.class.respond_to? :context
      assert self.class.respond_to? :contexts
    end

    class Default < Test::Unit::TestCase
      CONTEXT = context "When testing" do
        def test_this_thing
          true
        end
      end
      context "More testing" do
        # @todo implement more tests here ...
      end
    end

    setup do
      @default_context = Default::CONTEXT
    end
    
    test "[default context] sets the context name" do
      assert_equal "When testing", @default_context.context_name
    end

    test "[default context] is a Test::Unit::TestCase" do
      assert @default_context.ancestors.include?(Test::Unit::TestCase)
    end

    test "[default context] is defived from the test class" do
      assert_equal Default, @default_context.superclass
    end
    
    test "[default context] reports among test case's context defs" do
      assert Default.respond_to?(:context_definitions)
      assert_include Default.context_definitions, @default_context
      assert_equal 2, Default.context_definitions.size
    end
    
    test "has a (context name derived) class name" do
      namespace = 'Test::Unit::TestContext::Default::'
      assert_equal "#{namespace}ContextWhenTesting", @default_context.name
    end

    class Anonymous < Test::Unit::TestCase
      CONTEXT = context do
        def test_some_thing
          true
        end
      end
      context do
        test 'another_thing' do
        end
      end
      context do
        #
      end
    end
    
    setup do
      @anonymous_context = Anonymous::CONTEXT
    end

    test "[anonymous context] has a generated context name" do
      assert_not_nil @anonymous_context.name
    end
    
    test "[anonymous context] is defived from the test class" do
      assert_equal Anonymous, @anonymous_context.superclass
    end
    
    test "[anonymous context] reports among test case's context defs" do
      assert Anonymous.respond_to?(:context_definitions)
      assert_include Anonymous.context_definitions, @anonymous_context
      assert_equal 3, Anonymous.context_definitions.size
      assert_equal 3, Anonymous.context_definitions(true).size
    end
    
    test "[anonymous context] has a (context name derived) class name" do
      namespace = 'Test::Unit::TestContext::Anonymous::'
      context_name = @anonymous_context.context_name
      assert_equal "#{namespace}Context#{context_name}", @anonymous_context.name
    end
    
    class Nested < Test::Unit::TestCase
      CONTEXT = context "and we're testing" do
        @nested = context "should be nested" do
          def test_a_thing
            true
          end
        end
        def self.nested; @nested; end
      end
    end

    setup do
      @parent_context = Nested::CONTEXT
      @nested_context = Nested::CONTEXT.nested
    end
    
    test "[nested context] sets a nested context name" do
      assert_equal "and we're testing should be nested", @nested_context.context_name
    end

    test "[nested context] is also a Test::Unit::TestCase" do
      assert @nested_context.ancestors.include?(Test::Unit::TestCase)
    end

    test "[nested context] is defived from the prev context class" do
      assert_equal @parent_context, @nested_context.superclass
    end
    
    test "[nested context] reports context defs correctly" do
      assert Nested.respond_to?(:context_definitions)
      assert_equal 1, Nested.context_definitions.size
      assert_equal 1, @parent_context.context_definitions.size
      assert_equal 0, @nested_context.context_definitions.size
      assert_equal 2, Nested.context_definitions(true).size
    end
    
    test "[nested context] has a (context name derived) class name" do
      namespace = 'Test::Unit::TestContext::Nested::'
      assert_equal "#{namespace}ContextAndWeReTesting::ContextShouldBeNested", 
                    @nested_context.name
    end
    
    class Redefined < Test::Unit::TestCase
      CONTEXT = context 42 do
        def test_everything
          true
        end
      end
      @@warns = nil
      def self.warn(message)
        ( @@warns ||= [] ) << message
      end
      def self.warns; @@warns; end
      def self.reset_warns; @@warns = nil; end
    end

    setup do
      @redefined_context = Redefined::CONTEXT
    end
    
    test "[redefined context] sets the context name" do
      assert_equal 42, @redefined_context.context_name
    end

    test "[redefined context] warns when same context name used" do
      assert_nil Redefined.warns
      class Redefined
        context 42 do
          def test_something_else
            assert true
          end
        end
      end
      assert_not_nil Redefined.warns
      assert_equal 2, @redefined_context.instance_methods(false).grep(/test/).size
      
      Redefined.reset_warns
      
      assert_nil Redefined.warns
      class Redefined
        context '42' do # same class-name
          def test_a_little_thing
          end
        end
      end
      assert_not_nil Redefined.warns
      assert_equal 3, @redefined_context.instance_methods(false).grep(/test/).size
    end
    
  end
end
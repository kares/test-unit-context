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

    context "A new context" do
      
      context "when not nested" do
        setup do
          @context = 
            Class.new(Test::Unit::TestCase).
              context("When testing") do
                def test_this_thing
                  true
                end
              end
        end

        test "should set the context name" do
          assert_equal "When testing", @context.context_name
        end

        test "should be a Test::Unit::TestCase" do
          assert @context.ancestors.include?(Test::Unit::TestCase)
        end
        
      end

      context "when nested" do
        
        setup do
          @context = self.class.context("and we're testing") do
            def self.nested
              @nested
            end

            @nested = context "should be nested" do
              def test_this_thing
                true
              end
            end
          end
        end

        test "should set a nested context's name" do
          assert_equal "A new context when nested and we're testing should be nested", @context.nested.context_name
        end

        test "should also be a Test::Unit::TestCase" do
          assert @context.nested.ancestors.include?(Test::Unit::TestCase)
        end
        
      end
    end
    
  end
  
end
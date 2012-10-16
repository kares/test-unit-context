require File.expand_path('../../../test_helper', File.dirname(__FILE__))

module Test::Unit::Context
  class SharedTest < Test::Unit::TestCase
    
    def test_shared_aliases
      #%w(shared_behavior share_as share_behavior_as shared_examples_for).each do |method_alias|
        #assert self.class.respond_to?(method_alias.to_sym)
      #end
      assert self.class.respond_to?(:shared)
      assert self.class.respond_to?(:share_as)
    end

    def test_like_aliases
      #%w(uses it_should_behave_like behaves_like uses_examples_from).each do |method_alias|
        #assert self.class.respond_to?(method_alias.to_sym)
      #end
      assert self.class.respond_to? :like
      assert self.class.respond_to? :use
      assert self.class.respond_to? :uses
    end

    class << self; alias_method :it, :test; end
    
    context "A shared group" do
      context "creates a module" do
        
        test "based on a string name" do
          self.class.shared "things and fun" do
          end

          assert Shared::Behavior.const_defined?(:ThingsAndFun)
          assert_instance_of Shared::Behavior, Shared::Behavior.const_get(:ThingsAndFun)
        end

        test "based on a symbol name" do
          self.class.shared :fun_and_games do
          end

          assert Shared::Behavior.const_defined?(:FunAndGames)
          assert_instance_of Shared::Behavior, Shared::Behavior.const_get(:FunAndGames)
        end

        test "unless the name is not a String or Symbol" do
          assert_raise ArgumentError do
            self.class.shared 42 do
            end
          end
        end
        
      end

      context "should be locatable" do      
        shared "hello sir" do
          def amazing!
            puts "back off!"
          end
        end

        it "by a symbol" do
          assert_nothing_raised do
            self.class.use :hello_sir
          end
        end

        shared "hello madam" do
          def fantastic!
            puts "you know me!"
          end
        end

        it "by a string" do
          assert_nothing_raised do
            self.class.use "hello madam"
          end
        end

        shared "hi dog" do
          def stupendous!
            puts "hoo hah!"
          end
        end

        it "by direct reference" do
          assert_nothing_raised do
            self.class.use HiDog
          end
        end
        
        it "by behavior reference" do
          assert_nothing_raised do
            self.class.use Shared::Behavior::HiDog
          end
        end
      end

      context "should include its shared behavior" do
        shared "Athos" do
          test "en_garde" do
            true
          end
        end

        test "no en_garde" do
          assert_raise NoMethodError do 
            send("test: en_garde")
          end
        end
        
        context 'use by a symbol' do
          
          like :athos
          
          test "athos" do
            assert_nothing_raised do 
              send("test: en_garde")
            end
          end
          
        end

        shared "Porthos" do
          def parry!
            true
          end
        end

        test "by a string" do
          self.class.use "Porthos"
          assert parry!
        end

        shared "Aramis" do
          def lunge!
            true
          end
        end

        test "by direct reference" do
          self.class.uses Aramis
          assert lunge!
        end
        
      end
      
      test "locates all shared behaviors with their names" do
        assert_not_nil shareds = self.class.shared_definitions
        assert shareds.size >= 4, shareds.inspect
        assert_include shareds, Test::Unit::Context::Shared::Behavior::HiDog
        assert_equal 'hi dog', Test::Unit::Context::Shared::Behavior::HiDog.shared_name
        [ :Athos, :Porthos, :Aramis ].each do |name|
          assert_include shareds, behavior = self.class.const_get(name)
          assert_equal name.to_s, behavior.shared_name
        end
      end
      
    end
  end
end
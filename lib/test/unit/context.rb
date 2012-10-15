require "test/unit"
require "test/unit/context/helpers"
require "test/unit/context/version"

module Test
  module Unit
    module Context

      def context_list
        @context_list ||= []
      end
      
      # Add a context to a set of tests.
      # 
      #   context "A new account" do
      #     test "does not have users"
      #       assert Account.new.users.empty?
      #     end
      #   end
      # 
      # The context name is prepended to the test name, so failures look like this:
      # 
      #   1) Failure:
      #   test_a_new_account_does_not_have_users() [./test/test_accounts.rb:4]:
      #   <false> is not true.
      # 
      # Contexts can also be nested like so:
      # 
      #   context "A new account" do
      #     context "created from the web application" do
      #       test "has web as its vendor" do
      #         assert_equal "web", users(:web_user).vendor
      #       end
      #     end
      #   end
      #
      # Context should have unique names within a given scope, otherwise they 
      # end-up being merged as if it where one single context declaration. 
      # Anonymous (un-named) contexts are supported as well - contrary they 
      # never get merged (a unique name is generated for each such context).
      #
      def context(name = nil, &block)
        name ||= (Time.now.to_f * 1000).to_i
        # context "created with defaults" ... 'ContextCreatedWithDefaults'
        class_name = "Context#{Helpers.to_class_name(name.to_s)}"
        if const_defined?(class_name)
          klass = const_get(class_name)
          if ( klass.superclass == self rescue nil )
            warn "duplicate context definition with the name #{name.inspect} " << 
                  "found at #{caller.first} and is going to get merged with " << 
                  "the previous context definition"
          else
            raise "could not create a context with the name #{name.inspect} " << 
                  "as a constant #{class_name} is already defined and is not " << 
                  "another context definition"
          end
        else
          klass = Class.new(self)
          klass.extend ContextMethods
          klass.context_name = name
          # NOTE: make sure by default we run "inherited" setup/teardown hooks
          # unless context code does re-define the hook method e.g. `def setup` 
          # instead of using the `setup do` or the setup method marker syntax :
          klass.class_eval do
            def setup; super; end
            def cleanup; super; end
            def teardown; super; end
          end
          const_set(class_name, klass)
          self.context_list << klass
        end
        klass.class_eval(&block)
        klass
      end

      %w( contexts group ).each { |m| alias_method m, :context }
      
      module ContextMethods # :nodoc:
        
        def context_name
          if superclass.respond_to?(:context_name)
            "#{superclass.context_name} #{@context_name}".gsub(/^\s+/, "")
          else
            @context_name
          end
        end
        
        def context_name=(name); @context_name=name; end
        
      end
      
    end
  end
end

Test::Unit::TestCase.extend Test::Unit::Context

require "test/unit/context/shared"

Test::Unit::TestCase.extend Test::Unit::Context::Shared

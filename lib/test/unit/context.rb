require "test/unit"
require "test/unit/context/helpers"
require "test/unit/context/version"

module Test
  module Unit
    module Context

      def context_name #:nodoc:
        @context_name ||= ""
        if superclass.respond_to?(:context_name)
          return "#{superclass.context_name} #{@context_name}".gsub(/^\s+/, "")
        end
      end

      def context_name=(val) #:nodoc:
        @context_name = val
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
      def context(name, &block)
        klass = Class.new(self)
        klass.context_name = name
        # NOTE: make sure by default we run "inherited" setup/teardown hooks
        # unless context code does re-define the hook method e.g. `def setup` 
        # instead of using the `setup do` or the setup method marker syntax :
        klass.class_eval do
          def setup; super; end
          def cleanup; super; end
          def teardown; super; end
        end
        klass.class_eval(&block)

        #@@context_list << klass # make sure it's not GC-ed ?!
        class_name = Helpers.to_class_name(name)
        const_set("Test#{class_name}#{klass.object_id.abs}", klass)
        klass
      end

      %w( contexts group ).each { |m| alias_method m, :context }
      
      #@@context_list = []
      
    end
  end
end

Test::Unit::TestCase.extend Test::Unit::Context

require "test/unit/context/shared"

Test::Unit::TestCase.extend Test::Unit::Context::Shared

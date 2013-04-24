module Test::Unit::Context
  module Context

    PREFIX = 'Context'.freeze # :nodoc:
    SUFFIX = nil # :nodoc:
    
    # Add a context to a set of tests.
    # 
    #   context "A new account" do
    #     test "does not have users" do
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
      name ||= Helpers.generate_uuid
      # context "created with defaults" ... 'ContextCreatedWithDefaults'
      class_name = Helpers.to_const_name(name.to_s, PREFIX, SUFFIX)
      if const_defined?(class_name)
        klass = const_get(class_name)
        if ( klass.superclass == self rescue nil )
          warn "duplicate context definition with the name #{name.inspect} " << 
                "found at #{caller.first} it is going to be merged with " << 
                "the previous context definition"
        else
          raise "could not create a context with the name #{name.inspect} " << 
                "as a constant #{class_name} is already defined and is not " << 
                "another context definition"
        end
      else
        klass = Class.new(self)
        klass.extend Test::Unit::Context
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
      end
      context_definitions << klass
      klass.class_eval(&block)
      klass
    end

    %w( contexts group ).each { |m| alias_method m, :context }
    
    def context_definitions(nested = false)
      @_context_definitions ||= []
      if nested
        contexts = @_context_definitions.dup
        @_context_definitions.each do |context|
          contexts.concat context.context_definitions(nested)
        end
        contexts
      else
        @_context_definitions
      end
    end

  end
end
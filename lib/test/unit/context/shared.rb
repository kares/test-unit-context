module Test::Unit::Context
  module Shared
    
    # Share behavior among different contexts.
    # This creates a module (actually, a Module subclass) that is included 
    # using the +use+ method (or one of its aliases) provided by context (or 
    # +include+ if you know the module's constant name).
    #
    # ==== Examples
    #   
    #   shared "aasome-things" do
    #     test "does some thing" do
    #       # some-thing is awesome
    #     end
    #   end
    #
    #   like "aasome-things"
    #   # or 
    #   use "aasome-things"
    #
    #   share_as :client do
    #     test "is a client to our server" do
    #       # ...
    #     end
    #   end
    #
    #   like_a :client
    #   # or 
    #   uses "client"
    #
    def shared(name, &block)
      if ! name.is_a?(String) && ! name.is_a?(Symbol)
        raise ArgumentError, "use a String or Symbol as the name e.g. " + 
                             "`shared #{name.to_s.inspect} do ...`"  
      end
      const_name = Helpers.to_const_name(name.to_s)
      if Behavior.const_defined?(const_name)
        const = Behavior.const_get(const_name)
        if Behavior === const
          raise "duplicate shared definition with the name #{name.inspect} " <<
                 "found at #{caller.first} please provide an unique name"
        else
          raise "could not create a shared definition with the name " << 
                "#{name.inspect} as a constant #{Behavior.name}::#{const_name} " <<
                "already exists"
        end
      else
        behavior = Behavior.new(name, block)
        Behavior.const_set(const_name, behavior)
        # expose at current top-level test-case as a constant as well :
        test_case = self
        while test_case.is_a?(Test::Unit::Context)
          test_case = test_case.superclass
        end
        unless test_case.const_defined?(const_name)
          test_case.const_set(const_name, behavior)
        end
        behavior
      end
    end
    
    %w( share_as ).each { |m| alias_method m, :shared }
    
    # Pull in behavior shared by +shared+ or a module.  
    #
    # ==== Examples
    #   
    #   shared "awesome things" do
    #     test "does some thing" do
    #       # some-thing is awesome
    #     end
    #   end
    #
    #   like "awesome things"
    #
    #   module AwesomeThings
    #     # ...
    #   end
    #
    #   uses AwesomeThings
    #
    def like(shared_name)
      case shared_name
      when String, Symbol
        const_name = Helpers.to_const_name(shared_name.to_s)
        if Behavior.const_defined?(const_name)
          const = Behavior.const_get(const_name)
          if Behavior === const
            include const
          else
            raise "#{shared_name.inspect} does not resolve into a shared " << 
                   "behavior instance but to a #{const.inspect}"
          end
        else
          raise "shared behavior with name #{shared_name.inspect} not defined"
        end
      when Behavior, Module
        include shared_name
      else
        raise ArgumentError, "pass a String or Symbol as the name e.g. " +
                              "`like #{shared_name.to_s.inspect} do ...`"
      end
    end
    
    %w( like_a use uses ).each { |m| alias_method m, :like }
    
    # Returns all available shared definitions.
    def shared_definitions
      shareds = []
      constants.each do |name|
        const = const_get(name)
        if const.is_a?(Behavior)
          shareds << const
        end
      end
      shareds
    end
    
    class Behavior < Module
      
      attr_reader :shared_name
      
      def initialize(name, block)
        super()
        @shared_name = name
        @_block = block
      end

      def included(klass) # :nodoc:
        klass.class_eval(&@_block) # @_block.call
      end

    end
    
  end
end
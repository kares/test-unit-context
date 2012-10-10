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
      module_name = Helpers.to_module_name(name.to_s)
      Object.const_set(module_name, Behavior.create(block))
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
      when String
        module_name = Helpers.to_module_name(shared_name)
        include Object.const_get(module_name)
      when Symbol
        module_name = Helpers.to_module_name(shared_name.to_s)
        include Object.const_get(module_name)
      when Module, Behavior
        include shared_name
      else
        raise ArgumentError, "pass a String or Symbol as the name e.g. " +
                              "`like #{shared_name.to_s.inspect} do ...`"
      end
    end
    
    %w( like_a use uses ).each { |m| alias_method m, :like }
    
    class Behavior < Module

      def self.create(block) # :nodoc:
        self.new(block)
      end

      def initialize(block)
        super()
        @_block = block
      end

      def included(klass) # :nodoc:
        klass.class_eval(&@_block) # @_block.call
      end

    end
    
  end
end
require 'test/unit'
require 'test/unit/patches'
require 'test/unit/context/helpers'
require 'test/unit/context/version'

module Test
  module Unit
    module Context

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

require 'test/unit/context/context'
Test::Unit::TestCase.extend Test::Unit::Context::Context
require 'test/unit/context/shared'
Test::Unit::TestCase.extend Test::Unit::Context::Shared

# NOTE: this pollutes it's left to the user to load it :
# require 'test/unit/context/spec'
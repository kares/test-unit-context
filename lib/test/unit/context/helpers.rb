module Test::Unit::Context
  module Helpers
    
    module_function
    
    # Replaces spaces and tabs with _ so we can use the string as a method name
    # Also replace dangerous punctuation
    def to_method_name(str)
      name = str.downcase
      name.gsub!(/[\s:',\.~;!#=\(\)&]+/, '_')
      name
    end

    # Borrowed from +camelize+ in ActiveSupport
    def to_module_name(str)
      name = to_method_name(str)
      name.gsub!(/\/(.?)/) { "::#{$1.upcase}" }
      name.gsub!(/(?:^|_)(.)/) { $1.upcase }
      name
    end

    # Borrowed from +camelize+ in ActiveSupport
    def to_class_name(str)
      name = to_method_name(str)
      name.gsub!(/\/(.?)/) { $1.upcase }
      name.gsub!(/(?:^|_)(.)/) { $1.upcase }
      name
    end
    
  end
end
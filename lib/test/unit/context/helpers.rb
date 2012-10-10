module Test::Unit::Context
  module Helpers
    
    module_function
    
    # Replaces spaces and tabs with _ so we can use the string as a method name
    # Also replace dangerous punctuation
    def to_method_name(str)
      str.downcase.gsub(/[\s:',\.~;!#=\(\)&]+/,'_')
    end

    # Borrowed from +camelize+ in ActiveSupport
    def to_module_name(str)
      to_method_name(str).gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
    end

    # Borrowed from +camelize+ in ActiveSupport
    def to_class_name(str)
      to_method_name(str).gsub(/\/(.?)/) { "#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
    end
    
  end
end
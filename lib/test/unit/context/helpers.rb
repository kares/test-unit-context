module Test::Unit::Context
  module Helpers
    
    module_function
    
    def to_const_name(str, prefix = nil)
      name = prefix ? str.dup : str.lstrip
      name.gsub!(/[\s:',\.~;!#=\(\)&]+/, '_')
      name.gsub!(/\/(.?)/) { $1.upcase }
      name.gsub!(/(?:^|_)(.)/) { $1.upcase }
      prefix ? "#{prefix}#{name}" : name
    end
    
    def generate_uuid
      uuid = [ (Time.now.to_f * 1000).to_i % 10 ]
      15.times { uuid << rand(16).to_s(16) }
      uuid.join
    end
    
  end
end
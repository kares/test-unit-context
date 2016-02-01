require 'test/unit'

module Test::Unit
  unless const_defined? :TestSuiteCreator
    begin
      require 'test/unit/test-suite-creator' # TU 3.x
    rescue LoadError
      require 'test/unit/testsuitecreator' # <= 2.5.5
    end
  end
  TestSuiteCreator.class_eval do

    unless respond_to?(:test_method?)
      require 'test/unit/attribute' unless Test::Unit.const_defined? :Attribute
      if Test::Unit::Attribute::ClassMethods.method_defined?(:find_attribute)
        def self.test_method?(test_case, method_name)
          method_name = method_name.to_s
          ( method_name.start_with?('test') && method_name.length > 4 ) ||
            test_case.find_attribute(method_name, :test)
        end
      else
        def self.test_method?(test_case, method_name)
          method_name = method_name.to_s
          ( method_name.start_with?('test') && method_name.length > 4 ) ||
            test_case.attributes(method_name)[:test]
        end
      end
    end

    private

    def collect_test_names
      methods = @test_case.public_instance_methods(true)
      super_test_case = @test_case.superclass
      while super_test_case && super_test_case != TestCase
        methods -= super_test_case.public_instance_methods(true)
        super_test_case = super_test_case.superclass
      end
      method_names = methods.map!(&:to_s)
      test_names = method_names.find_all do |method_name|
        self.class.test_method?(@test_case, method_name)
      end
      __send__("sort_test_names_in_#{@test_case.test_order}_order", test_names)
    end

  end
end

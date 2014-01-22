require 'test/unit'
require 'test/unit/testsuitecreator'

module Test::Unit
  TestSuiteCreator.class_eval do

    private

    def collect_test_names
      methods = @test_case.public_instance_methods(true)
      test_case_super = @test_case.superclass
      while test_case_super && test_case_super != TestCase
        methods -= test_case_super.public_instance_methods(true)
        test_case_super = test_case_super.superclass
      end
      test_names = methods.map(&:to_s).find_all do |method_name|
        method_name =~ /^test./ or @test_case.attributes(method_name)[:test]
      end
      send("sort_test_names_in_#{@test_case.test_order}_order", test_names)
    end

  end
end
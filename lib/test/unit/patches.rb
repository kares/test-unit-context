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

    private

    def collect_test_names
      methods = @test_case.public_instance_methods(true)
      test_case_super = @test_case.superclass
      while test_case_super && test_case_super != TestCase
        methods -= test_case_super.public_instance_methods(true)
        test_case_super = test_case_super.superclass
      end
      methods.map!(&:to_s)
      use_find_attribute = @test_case.respond_to?(:find_attribute)
      test_names = methods.find_all do |method_name|
        # method_name =~ /^test./
        ( method_name.start_with?('test') && method_name.length > 4 ) ||
        ( use_find_attribute ? # since Test-Unit 3.0
            @test_case.find_attribute(method_name, :test) :
              @test_case.attributes(method_name)[:test] )
      end
      send("sort_test_names_in_#{@test_case.test_order}_order", test_names)
    end

  end
end

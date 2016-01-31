require File.expand_path('../../../test_helper', File.dirname(__FILE__))

module Test::Unit::Context
  class TestHooks < Test::Unit::TestCase

    class << self; alias_method :it, :test; end

    setup do
      @inherited_before_each_var ||= 0
      @inherited_before_each_var  += 1
    end

    attr_reader :inherited_before_each_var

    def setup
      @inherited_before_each_var   ||= 0
      @inherited_before_each_var_2 ||= 0
      @inherited_before_each_var    += 2
      @inherited_before_each_var_2  += 1
    end

    attr_reader :inherited_before_each_var_2

    def teardown
      @inherited_after_each_var ||= 0
      @inherited_after_each_var  += 1
    end

    attr_reader :inherited_after_each_var

    startup do
      @inherited_before_all_var ||= 0
      @inherited_before_all_var  += 1
    end

    attr_reader :inherited_before_all_var

    shutdown do
      @inherited_after_all_var ||= 0
      @inherited_after_all_var  += 1
    end

    attr_reader :inherited_after_all_var

    SAMPLE_TEST1 = context "hooks1" do

      setup do
        @inherited_before_each_var ||= 0
        @inherited_before_each_var  += 4
      end

      teardown do
        @after_each_var ||= 0
        @after_each_var  += 1
      end

      attr_reader :after_each_var

      teardown :a_method

      test "foo" do
        assert :foo
      end

      # @override so its not auto-run
      alias_method :default_run, :run
      def run(result); result end

    end

    setup
    def a_setup
      @superclass_before_each_var ||= 0
      @superclass_before_each_var  += 1
    end

    attr_reader :superclass_before_each_var

    teardown
    def a_teardown
      @superclass_after_each_var ||= 0
      @superclass_after_each_var  += 1
    end

    attr_reader :superclass_after_each_var

    context "with (inherited) setup/teadown hooks" do

      it "runs superclass before callbacks in order" do
        assert_equal 1, @test.superclass_before_each_var
      end

      it "runs inherited before callbacks in order" do
        assert_equal 7, @test.inherited_before_each_var
      end

      it "runs before callbacks in order" do
        assert_equal 1, @test.inherited_before_each_var_2
      end

      it "runs superclass after callbacks" do
        assert_equal 1, @test.superclass_after_each_var
      end

      it "runs inherited after callbacks" do
        assert_equal 1, @test.inherited_after_each_var
      end

      it "runs after callbacks" do
        assert_equal 1, @test.after_each_var
      end

      it "runs after callbacks specified with method names, instead of blocks" do
        assert_equal "a method ran", @test.ivar
      end

      setup do
        result = Test::Unit::TestResult.new
        @test = SAMPLE_TEST1.new("test: foo")
        @test.default_run(result) { |inherited_after_each_var, v| }
        verify_result_passed! result
      end

    end

    SAMPLE_TEST2 = context "hooks2" do

      setup do
        @inherited_before_each_var ||= 0
        @inherited_before_each_var  += 4
      end

      teardown do
        @after_each_var ||= 0
        @after_each_var  += 1
      end

      def setup
        @superclass_before_each_var ||= 0
        @inherited_before_each_var_2 ||= 9
      end

      def teardown
        @superclass_after_each_var ||= 0
      end

      attr_reader :after_each_var

      test "foo" do
        assert :foo
      end

      # @override so its not auto-run
      alias_method :default_run, :run
      def run(result); result end

    end

    context "with redefined setup/teadown methods" do

      setup do
        @result = Test::Unit::TestResult.new
        @test = SAMPLE_TEST2.new("test: foo")
        @test.default_run(@result) { |inherited_after_each_var, v| }
      end

      it "runs superclass before callbacks" do
        assert_equal 1, @test.superclass_before_each_var
      end

      it "runs superclass after callbacks" do
        assert_equal 1, @test.superclass_after_each_var
      end

      it "does not run inherited (re-defined) setup method" do
        assert_equal 9, @test.inherited_before_each_var_2
      end

      it "runs inherited before callbacks (except previous setup method)" do
        assert_equal 5, @test.inherited_before_each_var
      end

    end

    SAMPLE_TEST3 = context "hooks3" do

      setup do
        #puts "hooks3 setup \n  #{caller.join("\n  ")}"
        @inherited_before_each_var ||= 0
        @inherited_before_each_var  += 4
      end

      teardown do
        @after_each_var ||= 0
        @after_each_var  += 1
      end

      attr_reader :after_each_var

      test "foo" do
        assert :foo
      end

      # @override so its not auto-run
      alias_method :default_run, :run
      def run(result); result end

    end

    # test that we aren't stomping on defined setup method
    context "with setup/teardown methods" do

      SAMPLE_TEST3.class_eval { attr_reader :one, :two }

      setup
      def custom_setup

        #SAMPLE_TEST3.setup { @one = 1 }
        #SAMPLE_TEST3.teardown { @two = 10 }

        @test = SAMPLE_TEST3.new("test: foo")

        @test.class.setup do
          @one = 1
        end

        @test.class.teardown do
          @two = 10
        end

        result = Test::Unit::TestResult.new
        @test.default_run(result) { |inherited_after_each_var, v| }
        verify_result_passed! result
      end

      it "runs setup method block a la Shoulda" do
        assert_equal 1, @test.one
      end

      it "runs teardown method block a la Shoulda" do
        assert_equal 10, @test.two
      end

      it "runs teardown method block and regular callbacks" do
        assert_equal 7, @test.inherited_before_each_var
        assert_equal 1, @test.after_each_var
      end

    end

    def self.startup
      @superclass_before_all_var ||= 0
      @superclass_before_all_var  += 1
    end

    def self.shutdown
      @superclass_after_all_var ||= 0
      @superclass_after_all_var  += 1
    end

    protected

    attr_reader :ivar

    def a_method
      @ivar = "a method ran"
    end

    private

    def verify_result_passed!(test_result)
      unless test_result.passed?
        #raise test_result.faults[0] if test_result.faults.size == 1
        #raise "test run failed: #{result.summary}\n#{faults.inspect}"
        warn "test run failed: #{test_result.summary}\n#{test_result.inspect}"
        raise test_result.faults.first unless test_result.faults.empty?
      end
    end

  end

end
require File.expand_path('../../test_helper', File.dirname(__FILE__))

class PatchesTest < Test::Unit::TestCase

  self.test_order = :alphabetic

  @@tests_run = []

  def self.add_test(test)
    @@tests_run << test
  end

  module TestMethods

    def test_1
      PatchesTest.add_test :test_1
    end

  end

  include TestMethods

  def test_2
    PatchesTest.add_test :test_2
  end

  context do

    def test_3
      PatchesTest.add_test :test_3
    end

  end

  context 'empty' do

  end

  extend Test::Unit::Assertions

  def self.shutdown
    assert_equal [:test_1, :test_2, :test_3], @@tests_run
  end

end

#module TestMethods
#
#  def test_0
#    puts 0
#  end
#
#end
#
#class Test1 < Test::Unit::TestCase
#  include TestMethods
#
#  def test_1
#    puts 1
#  end
#
#  test
#  def a_test_1x
#    puts '1x'
#  end
#
#end
#
#class Test2 < Test1
#
#  def test_2
#    puts 2
#  end
#
#  test
#  def a_test_2x
#    puts '2x'
#  end
#
#end
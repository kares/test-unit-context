# #see spec_test.rb

class User42; end

describe User42 do
  
  it 'can create a new instance' do
    assert_nothing_raised do
      User42.new
    end
  end
  
  describe 'nested' do

    it 'sets SPEC_SAMPLE constant' do
      User42.const_set(:SPEC_SAMPLE, true)
    end
    
  end
  
end

describe User42, '#new' do
  
  setup do
    @user = User42.new
  end
  
  test 'setup a new instance' do
    assert_not_nil @user
    assert_instance_of User42, @user
  end
  
end

class Foo
  def bar; :baz; end
end

describe Foo, 'bar', :baz do
  
  it 'works' do
    assert_equal :'baz', Foo.new.bar
  end
  
end

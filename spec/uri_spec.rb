require 'murlsh'

describe URI do

  it 'should have its domain set to the domain of its URI if it is a valid HTTP URI' do
    URI('http://foo.com/').domain.should == 'foo.com'
  end

  it 'should have its domain set nil if it is not a valid HTTP URI' do
    URI('foo').domain.should be_nil
    URI('http://foo.com.').domain.should be_nil
  end

end

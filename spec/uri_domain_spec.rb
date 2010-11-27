require 'uri'

require 'murlsh'

describe URI do

  def uri_domain(s); URI(s).extend(Murlsh::URIDomain).domain; end

  it 'should have its domain set to the domain of its URI if it is a valid HTTP URI' do
    uri_domain('http://foo.com/').should == 'foo.com'
  end

  it 'should have its domain set nil if it is not a valid HTTP URI' do
    uri_domain('foo').should be_nil
    uri_domain('http://foo.com.').should be_nil
  end

  it 'should handle two letter top-level domains' do
    uri_domain('http://www.linux.fm/').should == 'linux.fm'
  end

end

require 'uri'

require 'murlsh'

Dir['plugins/*.rb'].each { |p| load p }

describe Murlsh::UriAsk do

  def asker(s)
    URI(s).extend(Murlsh::UriAsk)
  end

  # content type

  def content_type(s, options={})
    asker(s).content_type(options)
  end

  it 'should return an empty string for the content type of an empty string' do
    content_type('').should be_empty
  end

  it 'should return an empty string for the content type of a URI with an invalid hostname' do
    content_type('http://a.b/test/').should be_empty
  end

  it 'should return an empty string for the content type of a URI with a nonexistent path' do
    content_type(
      'http://matthewm.boedicker.org/does_not_exist/').should be_empty
  end

  it 'should return text/html for the content type of a valid URI that is text/html' do
    content_type('http://www.google.com/').should match /^text\/html/
  end

  it 'should return text/html for the content type of a valid https URI that is text/html' do
    content_type('https://msp.f-secure.com/web-test/common/test.html'
      ).should match /^text\/html/
  end

  it 'should return text/html for the content type of a URI that returns HTTP 203' do
    content_type('http://www.youtube.com/watch?v=Vxq9yj2pVWk'
      ).should match /^text\/html/
  end

  it 'should return an empty string for the content type of an invalid URI when given failproof option true' do
    content_type('http://x.boedicker.org/', :failproof => true).should be_empty
  end

  it 'should raise a SocketError when getting the content type of a URI with an invalid hostname when given failproof option false' do
    lambda { content_type('http://x.boedicker.org/', :failproof => false)
      }.should raise_error(SocketError)
  end

  it 'should raise an HTTPError when getting the content type of a URI with an invalid path when given failproof option false' do
    lambda { content_type('http://boedicker.org/invalid', :failproof => false)
      }.should raise_error(OpenURI::HTTPError)
  end

  it 'should limit redirects when getting content type' do
    content_type('http://matthewm.boedicker.org/redirect_test/'
      ).should == 'text/html'
  end

  # title

  def title(s, options={})
    asker(s).title(options)
  end

  it 'should return an empty title for an empty URI' do
    title('').should be_empty
  end

  it 'should return the URI as title for an invalid URI' do
    title('foo').should == 'foo'
  end

  it 'should return the URI as title for a URI with an invalid host' do
    title('http://28fac7a1ac51976c90016509d97c89ba.edu/'
      ).should == 'http://28fac7a1ac51976c90016509d97c89ba.edu/'
  end

  it 'should return the page title as title for a valid URI' do
    title('http://www.google.com/').should == 'Google'
  end

  it 'should return the URI as title for an invalid URI when the failproof option is true' do
    title('http://x.boedicker.org/', :failproof => true
      ).should == 'http://x.boedicker.org/'
  end

  it 'should raise a SocketError when trying to get the title of a URI with an invalid hostname when given failproof option false' do
    lambda { title('http://x.boedicker.org/', :failproof => false)
      }.should raise_error(SocketError)
  end

  it 'should raise an HTTPError when getting the title of a URI with an invalid path when given failproof option false' do
    lambda { title('http://boedicker.org/invalid', :failproof => false)
      }.should raise_error(OpenURI::HTTPError)
  end

end

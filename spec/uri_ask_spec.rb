require 'uri'

require 'fakeweb'

require 'murlsh'

describe Murlsh::UriAsk do

  before(:all) do
    # FakeWeb.allow_net_connect = false

    @url_invalid_host = 'http://x.boedicker.org/'

    @url_404 = 'http://matthewm.boedicker.org/does_not_exist/'
    [:get, :head].each do |method|
      FakeWeb.register_uri(method, @url_404, :status => ['404', 'Not Found'])
    end

    @url_200 = 'http://matthemw.boedicker.org/good/'
    FakeWeb.register_uri(:get, @url_200, :content_type => 'text/html',
      :status => ['200', 'OK'],
      :body => '<html><title>good</title><body></body></html>')
    FakeWeb.register_uri(:head, @url_200, :content_type => 'text/html',
      :status => ['200', 'OK'])

    @url_200_https = 'https://matthemw.boedicker.org/good/'
    FakeWeb.register_uri(:get, @url_200_https, :content_type => 'text/html',
      :status => ['200', 'OK'],
      :body => '<html><title>good</title><body></body></html>')
    FakeWeb.register_uri(:head, @url_200_https, :content_type => 'text/html',
      :status => ['200', 'OK'])

    @url_203 = 'http://matthewm.boedicker.org/203.html'
    [:get, :head].each do |method|
      FakeWeb.register_uri(method, @url_203, :content_type => 'text/html',
        :status => ['203', 'Non-Authoritative Information'])
    end

  end

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
    content_type(@url_invalid_host).should be_empty
  end

  it 'should return an empty string for the content type of a URI with a nonexistent path' do
    content_type(@url_404).should be_empty
  end

  it 'should return text/html for the content type of a valid URI that is text/html' do
    content_type(@url_200).should match(/^text\/html$/)
  end

  it 'should return text/html for the content type of a valid https URI that is text/html' do
    content_type(@url_200_https).should match(/^text\/html$/)
  end

  it 'should return text/html for the content type of a URI that returns HTTP 203' do
    content_type(@url_203).should match(/^text\/html$/)
  end

  it 'should return an empty string for the content type of an invalid URI when given failproof option true' do
    content_type(@url_invalid_host, :failproof => true).should be_empty
  end

  it 'should raise a SocketError when getting the content type of a URI with an invalid hostname when given failproof option false' do
    lambda { content_type(@url_invalid_host, :failproof => false)
      }.should raise_error(SocketError)
  end

  it 'should raise an HTTPError when getting the content type of a URI with an invalid path when given failproof option false' do
    lambda { content_type(@url_404, :failproof => false)
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
    title(@url_invalid_host).should == @url_invalid_host
  end

  it 'should return the page title as title for a valid URI' do
    title(@url_200).should == 'good'
  end

  it 'should return the URI as title for an invalid URI when the failproof option is true' do
    title(@url_invalid_host, :failproof => true).should == @url_invalid_host
  end

  it 'should raise a SocketError when trying to get the title of a URI with an invalid hostname when given failproof option false' do
    lambda { title(@url_invalid_host, :failproof => false)
      }.should raise_error(SocketError)
  end

  it 'should raise an HTTPError when getting the title of a URI with an invalid path when given failproof option false' do
    lambda { title(@url_404, :failproof => false)
      }.should raise_error(OpenURI::HTTPError)
  end

end

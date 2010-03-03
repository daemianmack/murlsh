$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'murlsh'

describe Murlsh::XhtmlResponse do
  Ie_ua = 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)'

  Non_ie_ua = 'Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.0.10) Gecko/2009042523 Ubuntu/9.04 (jaunty) Firefox/3.0.10'

  def get_content_type(accept, ua)
    req = Murlsh::XhtmlResponse.new
    req.set_content_type(accept, ua)
    req['Content-Type']
  end

  it 'should return application/xhtml+xml when accept is */* and it is not IE' do
    get_content_type('*/*', Non_ie_ua).should == 'application/xhtml+xml'
  end

  it 'should return text/html when accept is */* and it is IE' do
    get_content_type('*/*', Ie_ua).should == 'text/html'
  end

  it 'should return application/xhtml+xml when accept is */* and user agent is empty' do
    get_content_type('*/*', '').should == 'application/xhtml+xml'
  end

  it 'should return application/xhtml+xml when accept is */* and user agent is nil' do
    get_content_type('*/*', nil).should == 'application/xhtml+xml'
  end

  it 'should return application/xhtml+xml when accept is application/* and it is not IE' do
    get_content_type('application/*', Non_ie_ua).should == 'application/xhtml+xml'
  end

  it 'should return text/html when accept is application/* and it is IE' do
    get_content_type('application/*', Ie_ua).should == 'text/html'
  end

  it 'should return application/xhtml+xml when accept is application/* and user agent is empty' do
    get_content_type('application/*', '').should == 'application/xhtml+xml'
  end

  it 'should return application/xhtml+xml when accept is application/* and user agent is empty' do
    get_content_type('application/*', nil).should == 'application/xhtml+xml'
  end

  it 'should return application/xhtml+xml when accept is application/xhtml+xml and it is not IE' do
    get_content_type('application/xhtml+xml', Non_ie_ua).should == 'application/xhtml+xml'
  end

  it 'should return text/html when accept is application/xhtml+xml and it is not IE' do
    get_content_type('application/xhtml+xml', Ie_ua).should == 'text/html'
  end

  it 'should return application/xhtml+xml when accept is application/xhtml+xml and user agent is empty' do
    get_content_type('application/xhtml+xml', '').should == 'application/xhtml+xml'
  end

  it 'should return application/xhtml+xml when accept is application/xhtml+xml and user agent is nil' do
    get_content_type('application/xhtml+xml', nil).should == 'application/xhtml+xml'
  end

  it 'should return text/html when accept is text/html and it is not IE' do
    get_content_type('text/html', Non_ie_ua).should == 'text/html'
  end

  it 'should return text/html when accept is text/html and it is IE' do
    get_content_type('text/html', Ie_ua).should == 'text/html'
  end

  it 'should return text/html when accept is text/html and user agent is empty' do
    get_content_type('text/html', '').should == 'text/html'
  end

  it 'should return text/html when accept is text/html and user agent is nil' do
    get_content_type('text/html', nil).should == 'text/html'
  end

  it 'should return text/html when accept is empty and it is not IE' do
    get_content_type('', Non_ie_ua).should == 'text/html'
  end

  it 'should return text/html when accept is empty and it is IE' do
    get_content_type('', Ie_ua).should == 'text/html'
  end

  it 'should return text/html when accept is empty and user agent is empty' do
    get_content_type('', '').should == 'text/html'
  end

  it 'should return text/html when accept is empty and user agent is nil' do
    get_content_type('', nil).should == 'text/html'
  end

  it 'should return text/html when accept is nil and it is not IE' do
    get_content_type(nil, Non_ie_ua).should == 'text/html'
  end

  it 'should return text/html when accept is nil and it is IE' do
    get_content_type(nil, Ie_ua).should == 'text/html'
  end

  it 'should return text/html when accept is nil and user agent is empty' do
    get_content_type(nil, '').should == 'text/html'
  end

  it 'should return text/html when accept is nil and user agent is nil' do
    get_content_type(nil, nil).should == 'text/html'
  end

end

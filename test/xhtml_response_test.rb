$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'murlsh'

require 'spec/test/unit'

class XhtmlResponseTest < Test::Unit::TestCase

  Ie_ua = 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)'

  Non_ie_ua = 'Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.0.10) Gecko/2009042523 Ubuntu/9.04 (jaunty) Firefox/3.0.10'

  def get_content_type(accept, ua)
    req = Murlsh::XhtmlResponse.new
    req.set_content_type(accept, ua)
    req['Content-Type']
  end

  def test_star_star
    assert_equal('application/xhtml+xml',
      get_content_type('*/*', Non_ie_ua))
  end

  def test_star_star_ie
    assert_equal('text/html',
      get_content_type('*/*', Ie_ua))
  end

  def test_star_star_empty
    assert_equal('application/xhtml+xml',
      get_content_type('*/*', ''))
  end

  def test_star_star_nil
    assert_equal('application/xhtml+xml',
      get_content_type('*/*', nil))
  end

  def test_application_star
    assert_equal('application/xhtml+xml',
      get_content_type('application/*', Non_ie_ua))
  end

  def test_application_star_ie
    assert_equal('text/html',
      get_content_type('application/*', Ie_ua))
  end

  def test_application_star_empty
    assert_equal('application/xhtml+xml',
      get_content_type('application/*', ''))
  end

  def test_application_star_nil
    assert_equal('application/xhtml+xml',
      get_content_type('application/*', nil))
  end

  def test_application_xhtml_xml
    assert_equal('application/xhtml+xml',
      get_content_type('application/xhtml+xml', Non_ie_ua))
  end

  def test_application_xhtml_xml_ie
    assert_equal('text/html',
      get_content_type('application/xhtml+xml', Ie_ua))
  end

  def test_application_xhtml_xml_empty
    assert_equal('application/xhtml+xml',
      get_content_type('application/xhtml+xml', ''))
  end

  def test_application_xhtml_xml_nil
    assert_equal('application/xhtml+xml',
      get_content_type('application/xhtml+xml', nil))
  end

  def test_text_html
    assert_equal('text/html',
      get_content_type('text/html', Non_ie_ua))
  end

  def test_text_html_ie
    assert_equal('text/html',
      get_content_type('text/html', Ie_ua))
  end

  def test_text_html_empty
    assert_equal('text/html',
      get_content_type('text/html', ''))
  end

  def test_text_html_nil
    assert_equal('text/html',
      get_content_type('text/html', nil))
  end

  def test_empty
    assert_equal('text/html',
      get_content_type('', Non_ie_ua))
  end

  def test_empty_ie
    assert_equal('text/html',
      get_content_type('', Ie_ua))
  end

  def test_empty_empty
    assert_equal('text/html',
      get_content_type('', ''))
  end

  def test_empty_nil
    assert_equal('text/html',
      get_content_type('', nil))
  end

  def test_nil
    assert_equal('text/html',
      get_content_type(nil, Non_ie_ua))
  end

  def test_nil_ie
    assert_equal('text/html',
      get_content_type(nil, Ie_ua))
  end

  def test_nil_empty
    assert_equal('text/html',
      get_content_type(nil, ''))
  end

  def test_nil_nil
    assert_equal('text/html',
      get_content_type(nil, nil))
  end

end

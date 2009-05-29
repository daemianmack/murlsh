$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'murlsh'

require 'test/unit'

class XhtmlContentTypeTest < Test::Unit::TestCase

  Ie_ua = 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)'

  Non_ie_ua = 'Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.0.10) Gecko/2009042523 Ubuntu/9.04 (jaunty) Firefox/3.0.10'

  def test_star_star
    assert_equal('application/xhtml+xml',
      Murlsh.xhtml_content_type('*/*', Non_ie_ua))
  end

  def test_star_star_ie
    assert_equal('text/html', Murlsh.xhtml_content_type('*/*', Ie_ua))
  end

  def test_application_star
    assert_equal('application/xhtml+xml',
      Murlsh.xhtml_content_type('application/*', Non_ie_ua))
  end

  def test_application_star_ie
    assert_equal('text/html',
      Murlsh.xhtml_content_type('application/*', Ie_ua))
  end

  def test_application_xhtml_xml
    assert_equal('application/xhtml+xml',
      Murlsh.xhtml_content_type('application/xhtml+xml', Non_ie_ua))
  end

  def test_application_xhtml_xml_ie
    assert_equal('text/html',
      Murlsh.xhtml_content_type('application/xhtml+xml', Ie_ua))
  end

  def test_text_html
    assert_equal('text/html', Murlsh.xhtml_content_type('text/html', Non_ie_ua))
  end

  def test_text_html_ie
    assert_equal('text/html', Murlsh.xhtml_content_type('text/html', Ie_ua))
  end

  def test_accept_none
    assert_equal('text/html', Murlsh.xhtml_content_type('', Non_ie_ua))
  end

  def test_accept_none_ie
    assert_equal('text/html', Murlsh.xhtml_content_type('', Ie_ua))
  end

end

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'murlsh'

require 'test/unit'
require 'uri'

class GetContentTypeTest < Test::Unit::TestCase

  def test_nil
    assert_nil(Murlsh.get_content_type(nil))
  end

  def test_empty
    assert_nil(Murlsh.get_content_type(''))
  end

  def test_bad_url
    assert_nil(Murlsh.get_content_type('not a url'))
  end

  def test_bad_host
    assert_nil(Murlsh.get_content_type('http://a.b/test/'))
  end

  def test_bad_path
    assert_nil(Murlsh.get_content_type(
      'http://matthewm.boedicker.org/does_not_exist/'))
  end

  def test_good
    assert_match(/^text\/html/, Murlsh.get_content_type(
      'http://www.google.com/'))
  end

  def test_already_parsed
    assert_match(/^text\/html/, Murlsh.get_content_type(
      URI.parse('http://www.google.com/')))
  end

  def test_already_parsed_https
    assert_match(/^text\/html/, Murlsh.get_content_type(
      URI.parse('https://msp.f-secure.com/web-test/common/test.html')))
  end

end

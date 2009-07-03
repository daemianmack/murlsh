$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'murlsh'

require 'test/unit'
require 'uri'

class GetContentTypeTest < Test::Unit::TestCase

  def test_nil
    assert_equal('', Murlsh.get_content_type(nil))
  end

  def test_empty
    assert_equal('', Murlsh.get_content_type(''))
  end

  def test_bad_url
    assert_equal('', Murlsh.get_content_type('not a url'))
  end

  def test_bad_host
    assert_equal('', Murlsh.get_content_type('http://a.b/test/'))
  end

  def test_bad_path
    assert_equal('', Murlsh.get_content_type(
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

  def test_303
    # youtube returns a 303
    assert_match(/^text\/html/, Murlsh.get_content_type(
      'http://www.youtube.com/watch?v=vfxCnZ4Dp3c'))
  end

  def test_failproof_true
    assert_equal('', Murlsh.get_content_type('http://x.boedicker.org/',
      :failproof => true))
  end

  def test_failproof_false
    assert_raise SocketError do
      Murlsh.get_content_type('http://x.boedicker.org/', :failproof => false)
    end
  end

end

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'murlsh'

require 'spec/test/unit'
require 'uri'

class UriAskTest < Test::Unit::TestCase

  def asker(s)
    URI(s).extend(Murlsh::UriAsk)
  end

  # content type

  def content_type(s, options={})
    asker(s).content_type(options)
  end

  def test_empty
    assert_equal('', content_type(''))
  end

  def test_bad_host
    assert_equal('', content_type('http://a.b/test/'))
  end

  def test_bad_path
    assert_equal('', content_type(
      'http://matthewm.boedicker.org/does_not_exist/'))
  end

  def test_good
    assert_match(/^text\/html/, content_type('http://www.google.com/'))
  end

  def test_https
    assert_match(/^text\/html/, content_type(
      'https://msp.f-secure.com/web-test/common/test.html'))
  end

  def test_303
    # youtube returns a 303
    assert_match(/^text\/html/, content_type(
      'http://www.youtube.com/watch?v=Vxq9yj2pVWk'))
  end

  def test_failproof_true
    assert_equal('', content_type('http://x.boedicker.org/',
      :failproof => true))
  end

  def test_failproof_false
    assert_raise SocketError do
      content_type('http://x.boedicker.org/', :failproof => false)
    end
  end

  def test_redirect_limit
    assert_equal('text/html', content_type(
      'http://matthewm.boedicker.org/redirect_test/'))
  end

  # title

  def title(s, options={})
    asker(s).title(options)
  end

  def noop(url)
    assert_equal(url, title(url))
  end

  def test_title_empty
    noop('')
  end

  def test_title_invalid_url
    noop('foo')
  end

  def test_title_invalid_host
    noop('http://28fac7a1ac51976c90016509d97c89ba.edu/')
  end

  def test_title_good
    assert_equal('Google', title('http://www.google.com/'))
  end

  def test_title_failproof_true
    noop(title('http://x.boedicker.org/', :failproof => true))
  end

  def test_title_failproof_false
    assert_raise SocketError do
      title('http://x.boedicker.org/', :failproof => false)
    end
  end

end

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'murlsh'

require 'test/unit'

class GetTitleTest < Test::Unit::TestCase

  def noop(url)
    assert_equal(url, Murlsh.get_title(url))
  end

  def test_nil
    noop(nil)
  end

  def test_empty
    noop('')
  end

  def test_invalid_url
    noop('foo')
  end

  def test_invalid_host
    noop('http://28fac7a1ac51976c90016509d97c89ba.edu/')
  end

  def test_good
    assert_equal('Google', Murlsh.get_title('http://www.google.com/'))
  end

end

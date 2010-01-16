$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'murlsh'

require 'test/unit'

class UriTest < Test::Unit::TestCase

  def test_good
    assert_equal('foo.com', URI('http://foo.com/').domain)
  end

  def test_invalid
    assert_nil(URI('foo').domain)
  end

  def test_trailing_dot
    assert_nil(URI('http://foo.com.').domain)
  end

end

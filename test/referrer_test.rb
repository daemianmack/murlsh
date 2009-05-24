$:.unshift('..')

require 'murlsh'

require 'test/unit'

class ReferrerTest < Test::Unit::TestCase

  def setup
    @qmap = {
      /www\.foo\.com\/search/ => 'q',
    }
  end

  def instantiate(url)
    Murlsh::Referrer.new(url)
  end

  def test_url_nil
    r = instantiate(nil)
    assert_equal('', r.hostpath)
    assert_equal({}, r.query_string)
  end

  def test_url_nil_block
    r = instantiate(nil)
    r.search_query(@qmap) { |x| flunk }
  end

  def test_url_empty
    r = instantiate('')
    assert_equal('', r.hostpath)
    assert_equal({}, r.query_string)
  end

  def test_url_empty_block
    r = instantiate('')
    r.search_query(@qmap) { |x| flunk }
  end

  def test_hostpath_not_found
    r = instantiate('http://www.bar.com/search?q=test&a=1&b=2&c=3')
    assert_equal(nil, r.search_query(@qmap))
  end

  def test_hostpath_not_found_block
    r = instantiate('http://www.bar.com/search?q=test&a=1&b=2&c=3')
    r.search_query(@qmap) { |x| flunk }
  end

  def test_query_not_found
    r = instantiate('http://www.foo.com/search?a=1&b=2&c=3')
    assert_equal(nil, r.search_query(@qmap))
  end

  def test_query_not_found_block
    r = instantiate('http://www.foo.com/search?a=1&b=2&c=3')
    r.search_query(@qmap) { |x| flunk }
  end

  def test_good
    r = instantiate('http://www.foo.com/search?q=test&a=1&b=2&c=3')
    assert_equal('test', r.search_query(@qmap))
  end

  def test_good_block
    r = instantiate('http://www.foo.com/search?q=test&a=1&b=2&c=3')
    r.search_query(@qmap) { |x| assert_equal('test', x) }
  end

end

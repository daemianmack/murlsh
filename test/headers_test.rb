$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'murlsh'

require 'test/unit'

class HeadersTest < Test::Unit::TestCase

  def setup
    @h = Murlsh::Headers.new
  end

  def test_simple
    assert_equal("Content-Type: text/html\nStatus: 200 OK",
      @h.status('200 OK').content_type('text/html').to_s)
  end

  def test_cookie
    assert_equal("Set-Cookie: a=b; path=/; expires=Mon, 22 Jun 2015 00:00:00 GMT\nSet-Cookie: c=d; path=/; expires=Mon, 22 Jun 2015 00:00:00 GMT",
      @h.cookie(
        'expires' => Time.gm(2015, 6, 22),
        'name' => 'a',
        'path' => '/',
        'value' => 'b').cookie(
          'expires' => Time.gm(2015, 6, 22),
          'name' => 'c',
          'path' => '/',
          'value' => 'd').to_s)
  end

end

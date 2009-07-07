$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'murlsh'

require 'test/unit'

class MockRequest

  def initialize
    @method = 'GET'
    @qs = ''
    @stdin = ''
  end

  def in
    StringIO.new(@stdin)
  end

  def env
    { 'REQUEST_METHOD' => @method, 'QUERY_STRING' => @qs }
  end

  attr_accessor :method
  attr_accessor :qs
  attr_accessor :stdin
end

class ParseQueryTest < Test::Unit::TestCase

  def setup
    @req = MockRequest.new  
  end

  def test_simple_get
    @req.qs = 'a=1&b=2'
    assert_equal({ 'a' => '1', 'b' => '2' }, Murlsh.parse_query(@req))
  end

  def test_multiple_get
    @req.qs = 'a=1&b=2&a=2'
    assert_equal({ 'a' => '1', 'b' => '2' }, Murlsh.parse_query(@req))
  end

  def test_missing_get
    @req.qs = 'a=1&b=2'
    assert_nil(Murlsh.parse_query(@req)['c'])
  end

  def test_simple_post
    @req.method = 'POST'
    @req.stdin = 'a=1&b=2'
    assert_equal({ 'a' => '1', 'b' => '2' }, Murlsh.parse_query(@req))
  end

  def test_multiple_post
    @req.method = 'POST'
    @req.stdin = 'a=1&b=2&a=2'
    assert_equal({ 'a' => '1', 'b' => '2' }, Murlsh.parse_query(@req))
  end

  def test_missing_post
    @req.method = 'POST'
    @req.stdin = 'a=1&b=2'
    assert_nil(Murlsh.parse_query(@req)['c'])
  end

end

$:.unshift('..')

require 'murlsh'

require 'test/unit'

class ParseQueryTest < Test::Unit::TestCase

  def test_simple
    assert_equal({ 'a' => '1', 'b' => '2' }, Murlsh.parse_query('a=1&b=2'))
  end

  def test_multiple
    assert_equal({ 'a' => '1', 'b' => '2' }, Murlsh.parse_query('a=1&b=2&a=2'))
  end

  def test_missing
    assert_nil(Murlsh.parse_query('a=1&b=2')['c'])
  end

end

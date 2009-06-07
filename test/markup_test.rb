$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'murlsh'

require 'test/unit'

class MarkupTest < Test::Unit::TestCase

  def test_javascript_single
    m = Murlsh::Markup.new()
    m.javascript('test.js')
    assert_equal(
      '<script type="text/javascript" src="test.js"></script>', m)
  end

  def test_javascript_multiple
    m = Murlsh::Markup.new()
    m.javascript(['test1.js', 'test2.js'])
    assert_equal(
        '<script type="text/javascript" src="test1.js"></script><script type="text/javascript" src="test2.js"></script>',
      m)
  end

  def test_javascript_single_prefix
    m = Murlsh::Markup.new()
    m.javascript('test.js', :prefix => 'http://static.com/js/')
    assert_equal(
      '<script type="text/javascript" src="http://static.com/js/test.js"></script>', m)
  end

  def test_javascript_multiple_prefix
    m = Murlsh::Markup.new()
    m.javascript(['test1.js', 'test2.js'], :prefix => 'js/')
    assert_equal(
        '<script type="text/javascript" src="js/test1.js"></script><script type="text/javascript" src="js/test2.js"></script>',
      m)
  end

end

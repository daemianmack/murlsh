$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'murlsh'

require 'rubygems'
require 'hpricot'

require 'test/unit'

class GetCharsetTest < Test::Unit::TestCase

  def test_no_charset
    doc = Hpricot(<<eos
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"
 "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head></head>
<body></body>
</html>
eos
)
    assert_nil(Murlsh.get_charset(doc))
  end

end

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

%w{
hpricot

murlsh
}.each { |m| require m }

describe Murlsh::Doc do

  subject do
    html = <<eos
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
    <title>the title</title>
  </head>
<body>
  <h1>hi</h1>
</body>
</html>
eos
    Hpricot(html).extend(Murlsh::Doc)
  end

  its(:charset) { should == 'utf-8' }
  its(:title) { should == 'the title' }

end

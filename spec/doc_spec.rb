$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

%w{
hpricot

murlsh
}.each { |m| require m }

describe Murlsh::Doc do

  it 'should get the right title from an HTML page that has one' do
    html = <<eos
<html>
  <head>
    <title>the title</title>
  </head>
<body>
  <h1>hi</h1>
</body>
</html>
eos

    doc = Hpricot(html).extend(Murlsh::Doc)
    doc.title.should == 'the title'
  end

end

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

  it 'should get the right description from an HTML page that has one' do
    html = <<eos
<html>
  <head>
    <title>the title</title>
    <meta name="description" content="the description" />
  </head>
<body>
  <h1>hi</h1>
</body>
</html>
eos

    doc = Hpricot(html).extend(Murlsh::Doc)

    doc.description.should == 'the description'
  end

  it 'should return nil for an HTML page with no meta description tag' do
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

    doc.description.should be_nil
  end

end

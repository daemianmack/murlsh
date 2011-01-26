require 'open-uri'

require 'fakeweb'
require 'nokogiri'

require 'murlsh'

describe Murlsh::Doc do

  context 'when html has everything' do
    subject do
      html = <<eos
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
    <meta name="description" content="the description" />
    <title>the title</title>
  </head>
<body>
  <h1>hi</h1>
</body>
</html>
eos
      fake_url = 'http://everything.com/'
      FakeWeb.register_uri(:get, fake_url, :body => html)
      Nokogiri(open(fake_url)).extend(Murlsh::Doc)
    end

    its(:encoding) { should == 'utf-8' }
    its(:title) { should == 'the title' }
    its(:description) { should == 'the description' }
  end

  context 'when html has nothing' do
    subject do
      html = <<eos
<html>
  <head>
  </head>
<body>
  <h1>hi</h1>
</body>
</html>
eos
      fake_url = 'http://nothing.com/'
      FakeWeb.register_uri(:get, fake_url, :body => html)
      Nokogiri(open(fake_url)).extend(Murlsh::Doc)
    end

    its(:title) { should be_nil }
    its(:description) { should be_nil }
  end

end

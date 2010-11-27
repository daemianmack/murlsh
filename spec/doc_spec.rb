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
      Nokogiri(html).extend(Murlsh::Doc)
    end

    its(:charset) { should == 'utf-8' }
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
      Nokogiri(html).extend(Murlsh::Doc)
    end

    its(:charset) { should be_nil }
    its(:title) { should be_nil }
    its(:description) { should be_nil }
  end

end

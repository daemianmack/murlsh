$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'tempfile'
require 'time'

require 'murlsh'

describe Murlsh::AtomFeed do

  before do
    @url1 = stub('Url', 
      :content_type => 'text/html',
      :id => 1,
      :is_image? => false,
      :name => 'test 1',
      :time => Time.parse('dec 19 2009 12:34:56pm').utc,
      :title_stripped => 'test title',
      :url => 'http://matthewm.boedicker.org/',
      :via => 'http://www.google.com')

    @url2 = stub('Url',
      :content_type => 'image/jpeg',
      :id => 2,
      :is_image? => true,
      :name => 'test 2',
      :time => Time.parse('dec 20 2009 10:10:10am').utc,
      :title_stripped => 'image test',
      :url => 'http://matthewm.boedicker.org/test.jpg',
      :via => nil)

    @feed = Murlsh::AtomFeed.new('http://test.com/test/', :title => 'test')

    @expected = Regexp.new(<<EOS, Regexp::MULTILINE)
<\\?xml version="1\.0" encoding="UTF-8"\\?>
<feed xmlns="http://www\\.w3\\.org/2005/Atom">
  <id>http://test\\.com/test/</id>
  <link href="http://test\\.com/test/atom\\.xml" rel="self"/>
  <title>test</title>
  <updated>2009-12-20T15:10:10Z</updated>
  <entry>
    <author>
      <name>test 1</name>
    </author>
    <title>test title</title>
    <id>tag:test\\.com,2009-12-19:test\\.com/test/1</id>
    <summary>test title</summary>
    <updated>2009-12-19T17:34:56Z</updated>
    <link href="http://matthewm\\.boedicker\\.org/"/>
    <link type=".*"/>
  </entry>
  <entry>
    <author>
      <name>test 2</name>
    </author>
    <title>image test</title>
    <id>tag:test\\.com,2009-12-20:test\\.com/test/2</id>
    <summary>image test</summary>
    <updated>2009-12-20T15:10:10Z</updated>
    <link href="http://matthewm\\.boedicker\\.org/test\\.jpg"/>
    <link type=".*"/>
  </entry>
</feed>
EOS

  end

  it 'should generate the correct atom feed' do
    @feed.make([@url1, @url2], :indent => 2).should match @expected
  end

  it 'should write the correct atom feed to a file' do
    f = Tempfile.open('test_atom_feed')
    @feed.make([@url1, @url2], :indent => 2, :target => f)

    f.open
    f.read.should match @expected
    f.close
  end

end

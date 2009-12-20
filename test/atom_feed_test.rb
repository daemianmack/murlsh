$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'tempfile'
require 'time'

require 'murlsh'

require 'test/unit'

class AtomFeedTest < Test::Unit::TestCase

  class MockUrl

    def initialize(content_type, id, is_image, name, time, title_stripped,
      url, via)
      @content_type,
      @id,
      @is_image,
      @name,
      @time,
      @title_stripped,
      @url,
      @via =
        content_type,
        id,
        is_image,
        name,
        time,
        title_stripped,
        url,
        via
    end

    def is_image?; is_image; end

    attr_reader :content_type
    attr_reader :id
    attr_reader :is_image
    attr_reader :name
    attr_reader :time
    attr_reader :title_stripped
    attr_reader :url
    attr_reader :via
  end

  def test_atom_feed
    feed = Murlsh::AtomFeed.new('http://test.com/test/', :title => 'test')
    time1 = Time.parse('dec 19 2009 12:34:56pm').utc
    time2 = Time.parse('dec 20 2009 10:10:10am').utc

    entries = [
      MockUrl.new('text/html', 1, false, 'test 1', time1, 'test title',
        'http://matthewm.boedicker.org/', 'http://www.google.com'),
      MockUrl.new('image/jpeg', 2, true, 'test 2', time2, 'image test',
        'http://matthewm.boedicker.org/test.jpg', nil)
      ]

    expected = <<EOS
<?xml version="1.0" encoding="UTF-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <id>http://test.com/test/</id>
  <link href="http://test.com/test/atom.xml" rel="self"/>
  <title>test</title>
  <updated>2009-12-20T15:10:10Z</updated>
  <entry>
    <author>
      <name>test 1</name>
    </author>
    <title>test title</title>
    <id>tag:test.com,2009-12-19:test.com/test/1</id>
    <summary>test title</summary>
    <updated>2009-12-19T17:34:56Z</updated>
    <link href="http://matthewm.boedicker.org/"/>
    <link type="text/html" title="google.com" href="http://www.google.com" rel="via"/>
  </entry>
  <entry>
    <author>
      <name>test 2</name>
    </author>
    <title>image test</title>
    <id>tag:test.com,2009-12-20:test.com/test/2</id>
    <summary>image test</summary>
    <updated>2009-12-20T15:10:10Z</updated>
    <link href="http://matthewm.boedicker.org/test.jpg"/>
    <link type="image/jpeg" title="Full-size" href="http://matthewm.boedicker.org/test.jpg" rel="enclosure"/>
  </entry>
</feed>
EOS

    assert_equal(expected, feed.make(entries, :indent => 2))

    f = Tempfile.open('test_atom_feed')
    feed.make(entries, :indent => 2, :target => f)

    f.open
    assert_equal(expected, f.read)
    f.close

  end

end

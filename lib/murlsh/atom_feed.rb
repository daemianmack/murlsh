require 'rubygems'
require 'builder'

require 'uri'

module Murlsh

  class AtomFeed

    def initialize(root_url, options={})
      options = {
        :filename => 'atom.xml',
        :title => 'Atom feed' }.merge(options)
      @root_url = root_url
      @filename = options[:filename]
      @title = options[:title]

      setup_id_fields
    end

    def setup_id_fields
      uri_parsed = URI(@root_url)

      m = uri_parsed.host.match(/^(.*?)\.?([^.]+\.[^.]+)$/)

      @host, @domain = (m ? m.captures : [uri_parsed.host, ''])

      @path = uri_parsed.path
    end

    def make(entries, options={})
      xm = Builder::XmlMarkup.new(options)
      xm.instruct! :xml

      xm.feed(:xmlns => 'http://www.w3.org/2005/Atom') {
        xm.id(@root_url)
        xm.link(:href => URI.join(@root_url, @filename), :rel => 'self')
        xm.title(@title)
        xm.updated(entries.collect { |mu| mu.time }.max.xmlschema)
        entries.each do |mu|
          xm.entry {
            xm.author { xm.name(mu.name) }
            xm.title(mu.title)
            xm.id(entry_id(mu))
            xm.summary(mu.title)
            xm.updated(mu.time.xmlschema)
            xm.link(:href => mu.url)
            enclosure(xm, mu)
          }
        end
      }
      xm
    end

    def entry_id(url)
      "tag:#{@domain},#{url.time.strftime('%Y-%m-%d')}:#{@host}#{@path}#{url.id}"
    end

    def enclosure(xm, mu)
      xm.link(:rel => 'enclosure', :type => mu.content_type, :href => mu.url,
        :title => 'Full-size') if mu.is_image?
    end

  end

end

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
      uri_parsed = URI.parse(@root_url)
      @host, @domain = uri_parsed.host.match(
        /^(.*?)\.?([^.]+\.[^.]+)$/).captures
      @path = uri_parsed.path
    end

    def make(entries, options={})
      xm = Builder::XmlMarkup.new(options)
      xm.instruct! :xml

      xm.feed(:xmlns => 'http://www.w3.org/2005/Atom') {
        xm.id(@root_url)
        xm.link(:href => "#{@root_url}#{@filename}", :rel => 'self')
        xm.title(@title)
        xm.updated(entries.collect { |mu| mu.time }.max.xmlschema)
        entries.each do |mu|
          xm.entry {
            xm.author { xm.name(mu.name) }
            xm.title(mu.title)
            xm.id("tag:#{@domain},#{mu.time.strftime('%Y-%m-%d')}:#{@host}#{@path}#{mu.id}")
            xm.summary(mu.title)
            xm.updated(mu.time.xmlschema)
            xm.link(:href => mu.url)
          }
        end
      }
      xm
    end

  end

end

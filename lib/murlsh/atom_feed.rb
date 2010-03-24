%w{
uri

builder
}.each { |m| require m }

module Murlsh

  # ATOM feed builder.
  class AtomFeed

    # root_url is the base url for the feed items.
    #
    # Options:
    # * :filename - the file name of the feed (atom.xml)
    # * :title - the feed title
    def initialize(root_url, options={})
      options = {
        :filename => 'atom.xml',
        :title => 'Atom feed',
        :hubs => []}.merge(options)
      @root_url = root_url
      @filename = options[:filename]
      @title = options[:title]
      @hubs = options[:hubs]

      root_uri = URI(@root_url)

      @host, @domain, @path = root_uri.host, root_uri.domain, root_uri.path
    end

    # Generate the feed and write it to the filesystem with locking.
    def write(entries, path)
      Murlsh::openlock(path, 'w') { |f| make(entries, :target => f) }
    end

    # Build the feed using XML builder. Options are passed to
    # Builder::XmlMarkup.new.
    def make(entries, options={})
      xm = Builder::XmlMarkup.new(options)
      xm.instruct!(:xml)

      xm.feed(:xmlns => 'http://www.w3.org/2005/Atom') {
        xm.id(@root_url)
        xm.link(:href => URI.join(@root_url, @filename), :rel => 'self')
        @hubs.each { |hub| xm.link(:href => hub, :rel => 'hub') }
        xm.title(@title)
        xm.updated(entries.collect { |mu| mu.time }.max.xmlschema)
        entries.each do |mu|
          xm.entry {
            xm.author { xm.name(mu.name) }
            xm.title(mu.title_stripped)
            xm.id(entry_id(mu))
            xm.summary(mu.title_stripped)
            xm.updated(mu.time.xmlschema)
            xm.link(:href => mu.url)
            enclosure(xm, mu)
            via(xm, mu)
          }
        end
      }
    end

    # Build the entry's id.
    def entry_id(url)
      "tag:#{@domain},#{url.time.strftime('%Y-%m-%d')}:#{@host}#{@path}#{url.id}"
    end

    # Add an ATOM enclosure if the url is an image.
    def enclosure(xm, mu)
      xm.link(:rel => 'enclosure', :type => mu.content_type, :href => mu.url,
        :title => 'Full-size') if mu.is_image?
    end

    def via(xm, mu)
      Murlsh::failproof do
        xm.link(:rel => 'via', :type => 'text/html', :href => mu.via,
          :title => URI(mu.via).domain) if mu.via
      end
    end

  end

end

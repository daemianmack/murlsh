require 'uri'

require 'murlsh'

module Murlsh

  # Show the domain of the url.
  class UrlDisplayAdd50HostRec < Plugin

    @hook = 'url_display_add'

    # Show the domain of the url.
    def self.run(markup, url, config)
      if domain = Murlsh::failproof { URI(url.url).domain }
        # show domain if not already contained in title and not on skip list
        unless (url.title and url.title.downcase.index(domain)) or
          skips.include?(domain)
          markup.span(" [#{domain}]", :class => 'host')
        end
      end
    end

    @skips = %w{
      wikipedia.org
      flickr.com
      github.com
      twitpic.com
      twitter.com
      vimeo.com
      youtube.com
      }
    class << self; attr_reader :skips; end

  end

end

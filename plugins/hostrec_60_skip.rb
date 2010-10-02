module Murlsh

  # Skip showing host record for some domains.
  class Hostrec60Skip < Plugin

    @hook = 'hostrec'

    def self.run(domain, url, title)
      domain unless skips.include?(domain)
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

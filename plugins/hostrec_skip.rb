module Murlsh

  # skip showing host record for some domains
  class HostrecSkip < Plugin

    Hook = 'hostrec'

    def self.run(domain, url, title)
      domain unless Skips.include?(domain)
    end

    Skips = %w{
      wikipedia.org
      flickr.com
      github.com
      twitter.com
      vimeo.com
      youtube.com
      }

  end

end

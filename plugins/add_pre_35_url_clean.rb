require 'uri'

require 'postrank-uri'

require 'murlsh'

module Murlsh

  # Canonicalize and clean urls with postrank-uri.
  #
  # See https://github.com/postrank-labs/postrank-uri
  class AddPre35UrlClean < Plugin

    @hook = 'add_pre'

    def self.run(url, config)
      url.url = PostRank::URI.clean(url.url)  if cleanable?(url.url)
      url.via = PostRank::URI.clean(url.via)  if cleanable?(url.via)
    end

    # Return true if the url can be cleaned by postrank-uri.
    #
    # Postrank::URI.clean only works on https or https urls.
    def self.cleanable?(url)
      Murlsh::failproof { URI(url).scheme.to_s.match(/^https?$/i) }
    end

  end

end

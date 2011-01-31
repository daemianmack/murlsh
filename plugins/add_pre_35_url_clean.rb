require 'postrank-uri'

require 'murlsh'

module Murlsh

  # Canonicalize and clean urls with postrank-uri.
  #
  # See https://github.com/postrank-labs/postrank-uri
  class AddPre35UrlClean < Plugin

    @hook = 'add_pre'

    def self.run(url, config)
      url.url = PostRank::URI.clean(url.url)
      url.via = PostRank::URI.clean(url.via)  if url.via
    end

  end

end

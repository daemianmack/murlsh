require 'rubygems'
require 'active_record'

require 'uri'

module Murlsh

  # URL ActiveRecord.
  class Url < ActiveRecord::Base

    # Get the title of this url.
    def title
      read_attribute(:title) || read_attribute(:url) || 'title missing'
    end

    # Title with whitespace compressed and leading and trailing whitespace
    # stripped.
    def title_stripped; title.strip.gsub(/\s+/, ' '); end

    # Return true if this url has the same author as another url.
    def same_author?(other)
      other and other.email and other.name and
        email and name and email == other.email and name == other.name
    end

    # Return text showing what domain a link goes to.
    def hostrec
      domain = Murlsh::failproof { URI(url).domain }

      domain = Murlsh::Plugin.hooks('hostrec').inject(domain) {
        |result,plugin| plugin.run(result, url, title) }

      yield domain if domain
    end

    # Yield the url that the url came from.
    def viarec; Murlsh::failproof { yield URI(via) } if via; end

    # Return true if this url is an image.
    def is_image?
      %w{image/gif image/jpeg image/png}.include?(content_type)
    end

  end

end

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

    # Return true if this url has the same author as another url.
    def same_author?(other)
      other and other.email and other.name and
        email and name and email == other.email and name == other.name
    end

    # Well-known sites to skip showing the domain for.
    Widely_known = %w{
      wikipedia.org
      flickr.com
      github.com
      twitter.com
      vimeo.com
      youtube.com
      }

    # Return text showing what domain a link goes to.
    def hostrec
      begin
        domain = URI(url).host[/[a-z\d-]+\.[a-z]{2,}(\.[a-z]{2})?$/].downcase
      rescue Exception => e
        domain = nil
      end
      yield domain unless !domain or title.downcase.index(domain) or
        Widely_known.include?(domain)
    end

    # Return true if this url is an image.
    def is_image?
      %w{image/gif image/jpeg image/png}.include?(content_type)
    end

  end

end

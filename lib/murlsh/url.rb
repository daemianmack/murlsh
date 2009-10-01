require 'rubygems'
require 'active_record'

require 'uri'

module Murlsh

  class Url < ActiveRecord::Base

    def same_author?(other)
      other and other.email and other.name and
        email and name and email == other.email and name == other.name
    end

    Widely_known = %w{
      wikipedia.org
      flickr.com
      github.com
      twitter.com
      vimeo.com
      youtube.com
      }

    def hostrec
      begin
        domain = URI(url).host[/[a-z\d-]+\.[a-z]{2,}(\.[a-z]{2})?$/].downcase
      rescue Exception => e
        domain = nil
      end
      yield domain unless !domain or title.downcase.index(domain) or
        Widely_known.include?(domain)
    end

    def is_image?
      %w{image/gif image/jpeg image/png}.include?(content_type)
    end

  end

end

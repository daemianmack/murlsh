require 'rubygems'
require 'active_record'

require 'uri'

module Murlsh

  class Url < ActiveRecord::Base

    def same_author?(other)
      other and other.email and other.name and
        email and name and email == other.email and name == other.name
    end

    Widely_known = [
      'en.wikipedia.org',
      'flickr.com',
      'github.com',
      'twitter.com',
      'vimeo.com',
      'youtube.com',
      ]

    def hostrec
      begin
        host = URI.parse(url).host.sub(/^(www)\./, '')
      rescue Exception => e
        host = nil
      end
      yield host unless !host or (title.downcase.index(host.downcase) or
        Widely_known.include?(host))
    end

  end

end

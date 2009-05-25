require 'rubygems'
require 'json'

require 'uri'

module Murlsh

  class Url

    def initialize(d={})
      d.each_pair { |k,v| send("#{k}=", v) if respond_to?("#{k}=") }
    end

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

    def to_json(*a)
      {
        'id' => id,
        'time' => time,
        'url' => url,
        'email' => email,
        'name' => name,
        'title' => title
      }.to_json(*a)
    end

    attr_accessor :id
    attr_accessor :time
    attr_accessor :url
    attr_accessor :email
    attr_accessor :name
    attr_accessor :title
  end

end

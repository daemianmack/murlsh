require 'hostrec'

require 'rubygems'
require 'json'

require 'cgi'
require 'uri'

module Murlsh

  class Url
    include HostRec

    def initialize(d={})
      d.each_pair { |k,v| send("#{k}=", v) if respond_to?("#{k}=") }
    end

    def same_author?(other)
      other and other.email and other.name and
        email and name and email == other.email and name == other.name
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

  class Referrer

    def initialize(url)
      @url = url

      begin
        url_parsed = URI.parse(url)
        @hostpath = url_parsed.host + url_parsed.path
        @query_string =
          url_parsed.query.nil? ? {} : CGI::parse(url_parsed.query)
      rescue Exception => e
        @hostpath = ''
        @query_string = {}
      end
    end

    def search_query(qmap=Qmap)
      if hostpath and query_string
        qmap.each_pair do |r,v|
          if hostpath.match(r) and !query_string[v].empty?
            if block_given?
              yield query_string[v].first
            else
              return query_string[v].first
            end
          end
        end
      end
      nil
    end

    Qmap = {
      /^www\.google\.(com|dk)\/search$/ => 'q',
    }

    attr_accessor :url
    attr_reader :hostpath
    attr_reader :query_string
  end

end

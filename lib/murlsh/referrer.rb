require 'cgi'
require 'uri'

module Murlsh

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
          if hostpath[r] and !query_string[v].empty?
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
      /^www\.google\.(com|cz|dk|es)(\/m)?\/search$/ => 'q',
      /^www\.bing\.com\/search$/ => 'q',
    }

    attr_accessor :url
    attr_reader :hostpath
    attr_reader :query_string
  end

end

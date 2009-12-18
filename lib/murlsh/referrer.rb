require 'cgi'
require 'uri'

module Murlsh

  # For parsing query strings from referring search engines.
  class Referrer

    def initialize(url)
      @url = url

      begin
        url_parsed = URI(url)
        @hostpath = url_parsed.host + url_parsed.path
        @query_string =
          url_parsed.query.nil? ? {} : CGI::parse(url_parsed.query)
      rescue Exception
        @hostpath = ''
        @query_string = {}
      end
    end

    # Get the searched for string from a search engine query string.
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

    # Regex host match to name of query string parameter.
    Qmap = {
      /^www\.google\.(bs|ca|com|cz|dk|es|fi|it|nl|no)(\/m)?\/search$/ => 'q',
      /^www\.bing\.com\/search$/ => 'q',
    }

    attr_accessor :url
    attr_reader :hostpath
    attr_reader :query_string
  end

end

require 'net/http'
require 'net/https'
require 'open-uri'
require 'uri'

require 'nokogiri'
require 'htmlentities'
require 'iconv'

module Murlsh

  # URI mixin.
  module UriAsk

    # Get the content length.
    #
    # Options:
    # * :failproof - if true hide all exceptions and return empty string on failure
    # * :headers - hash of headers to send in request
    def content_length(options={}); header 'content-length', options; end

    # Get the content type.
    #
    # Options:
    # * :failproof - if true hide all exceptions and return empty string on failure
    # * :headers - hash of headers to send in request
    def content_type(options={}); header 'content-type', options; end

    # Get the HTML title.
    #
    # Options:
    # * :failproof - if true hide all exceptions and return url on failure
    # * :headers - hash of headers to send in request
    def title(options={})
      return @title  if defined?(@title)

      @title = to_s

      d = doc(options)

      if d and d.title and not d.title.empty?; @title = decode(d.title); end

      @title
    end
 
    # Get the HTML meta description.
    #
    # Options:
    # * :failproof - if true hide all exceptions and return empty string on failure
    # * :headers - hash of headers to send in request
    def description(options={})
      return @description  if defined?(@description)

      @description = ''

      d = doc(options)

      if d and d.description and not d.description.empty?
        @description = decode(d.description)
      end

      @description
    end

    # Get the parsed Nokogiri doc at this url.
    #
    # Options:
    # * :failproof - if true hide all exceptions and return empty string on failure
    # * :headers - hash of headers to send in request
    def doc(options={})
      return @doc  if defined?(@doc)
      options[:headers] = default_headers.merge(options.fetch(:headers, {}))

      @doc = nil
      if html?(options)
        Murlsh::failproof(options) do
          self.open(options[:headers]) do |f|
            data = f.read
            @doc = Nokogiri(data, to_s)
            # encoding unknown, reparse with f.charset, default to UTF-8
            unless @doc.encoding
              @doc = Nokogiri(data, to_s, f.charset || 'UTF-8')
            end
            @doc.extend(Murlsh::Doc)
          end
        end
      end

      @doc
    end

    # Default headers sent with the request.
    def default_headers
      result = {
        'User-Agent' =>
          'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.4) Gecko/20030624',
        }
      if host.to_s[/^www\.nytimes\.com/]
        result['Referer'] = 'http://news.google.com/'
      end

      result
    end

    HtmlContentTypePattern = %r{^text/html}i

    # Return true if the content type is HTML.
    def html?(options={}); content_type(options)[HtmlContentTypePattern]; end

    # Convert from the character set of this url to utf-8 and decode HTML
    # entities.
    def decode(s)
      HTMLEntities.new.decode(Iconv.conv('utf-8', doc.encoding, s))
    end

    # Get the value of a response header.
    #
    # Options:
    # * :failproof - if true hide all exceptions and return empty string on failure
    # * :headers - hash of headers to send in request
    def header(header_name, options={})
      result = [*head_headers(options)[header_name]][0]
      result = get_headers(options)[header_name]  if not result or result.empty?
      result.to_s
    end

    # Get and cache response headers returned by HTTP HEAD for this URI.
    #
    # Return hash values are lists.
    #
    # Options:
    # * :failproof - if true hide all exceptions and return empty hash on failure
    # * :headers - hash of headers to send in request
    def head_headers(options={})
      return @head_headers  if defined?(@head_headers)

      request_headers = default_headers.merge(options.fetch(:headers, {}))

      response_headers = {}
      Murlsh::failproof(options) do
        http = Net::HTTP.new(host, port)
        http.use_ssl = (scheme == 'https')

        extend(Murlsh::URIGetPathQuery)
        resp = http.request_head(get_path_query, request_headers)

        if Net::HTTPSuccess === resp
          response_headers = resp.to_hash
        end
      end

      @head_headers = response_headers
    end

    # Get and cache response headers returned by HTTP GET for this URI.
    #
    # Return hash values are single strings.
    #
    # Options:
    # * :failproof - if true hide all exceptions and return empty hash on failure
    # * :headers - hash of headers to send in request
    def get_headers(options={})
      return @get_headers  if defined?(@get_headers)

      request_headers = default_headers.merge(options.fetch(:headers, {}))

      response_headers = {}
      # use open-uri instead of Net::HTTP because it handles redirects
      Murlsh::failproof(options) do
        response_headers = self.open(request_headers) { |f| f.meta }
      end

      @get_headers = response_headers
    end

  end

end

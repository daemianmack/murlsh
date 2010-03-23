require 'net/http'
require 'net/https'
require 'open-uri'
require 'uri'

require 'hpricot'
require 'htmlentities'
require 'iconv'

module Murlsh

  # URI mixin.
  module UriAsk

    # Get the content type.
    #
    # Options:
    # * :failproof - if true hide all exceptions and return empty string on failure
    # * :headers - hash of headers to send in request
    def content_type(options={})
      return @content_type if defined?(@content_type)
      options[:headers] = default_headers.merge(options.fetch(:headers, {}))

      @content_type = ''
      Murlsh::failproof(options) do
        # try head first to save bandwidth
        http = Net::HTTP.new(host, port)
        http.use_ssl = (scheme == 'https')

        resp = http.request_head(path_query, options[:headers])
        @content_type = case resp
          when Net::HTTPSuccess then resp['content-type']
          else self.open(options[:headers]) { |f| f.content_type }
        end
      end
      @content_type
    end

    # Get the HTML title.
    #
    # Options:
    # * :failproof - if true hide all exceptions and return empty string on failure
    # * :headers - hash of headers to send in request
    def title(options={})
      return @title if defined?(@title)
      options[:headers] = default_headers.merge(options.fetch(:headers, {}))

      @title = to_s
      if might_have_title?(options)
        Murlsh::failproof(options) do
          self.open(options[:headers]) do |f|
            doc = Hpricot(f).extend(Murlsh::Doc)

            if doc.title and !doc.title.empty?
              @title = HTMLEntities.new.decode(Iconv.conv('utf-8',
                doc.charset || f.charset, doc.title))
            end
          end
        end
      end
      @title
    end

    # Default headers sent with the request.
    def default_headers
      result = {
        'User-Agent' =>
          'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.4) Gecko/20030624',
        }
      if (host || '')[/^www\.nytimes\.com/]
        result['Referer'] = 'http://news.google.com/'
      end

      result
    end

    # Return true if the content type is likely to have a title that can be
    # parsed.
    def might_have_title?(options={})
      content_type(options)[/^text\/html/]
    end

  end

end

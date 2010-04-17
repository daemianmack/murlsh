%w{
net/http
net/https
open-uri
uri

hpricot
htmlentities
iconv
}.each { |m| require m }

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
    # * :failproof - if true hide all exceptions and return url on failure
    # * :headers - hash of headers to send in request
    def title(options={})
      return @title if defined?(@title)

      @title = to_s

      d = doc(options)

      if d and d.title and !d.title.empty?
        @title = decode(d.title)
      end

      @title
    end
 
    # Get the HTML meta description.
    #
    # Options:
    # * :failproof - if true hide all exceptions and return empty string on failure
    # * :headers - hash of headers to send in request
    def description(options={})
      return @description if defined?(@description)

      @description = ''

      d = doc(options)

      if d and d.description and !d.description.empty?
        @description = decode(d.description)
      end

      @description
    end

    # Get the parsed Hpricot doc at this url.
    #
    # Options:
    # * :failproof - if true hide all exceptions and return empty string on failure
    # * :headers - hash of headers to send in request
    def doc(options={})
      return @doc if defined?(@doc)
      options[:headers] = default_headers.merge(options.fetch(:headers, {}))

      @doc = nil
      if html?(options)
        Murlsh::failproof(options) do
          self.open(options[:headers]) do |f|
            @doc = Hpricot(f).extend(Murlsh::Doc)

            @charset = @doc.charset || f.charset
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
      if (host || '')[/^www\.nytimes\.com/]
        result['Referer'] = 'http://news.google.com/'
      end

      result
    end

    # Return true if the content type is HTML.
    def html?(options={})
      content_type(options)[/^text\/html/]
    end

    # Convert from the character set of this url to utf-8 and decode HTML
    # entities.
    def decode(s)
      HTMLEntities.new.decode(Iconv.conv('utf-8', @charset, s))
    end

  end

end

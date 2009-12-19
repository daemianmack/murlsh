require 'open-uri'
require 'uri'

require 'rubygems'
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
      options = default_options(options)

      @content_type = ''
      begin
        @content_type = self.open(options[:headers]) { |f| f.content_type }
      rescue Exception
        raise unless options[:failproof]
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
      options = default_options(options)

      @title = to_s
      begin
        if might_have_title(options)
          f = self.open(options[:headers])
          doc = Hpricot(f).extend(Murlsh::Doc)

          @title = HTMLEntities.new.decode(Iconv.conv('utf-8',
            doc.charset || f.charset, doc.title))
        end
      rescue Exception
         raise unless options[:failproof]
      end
      @title
    end

    # Default options overlaid with passed in options.
    def default_options(options={})
      options[:headers] = default_headers.merge(options.fetch(:headers, {}))

      {
        :failproof => true,
        }.merge(options)
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
    def might_have_title(options={})
      content_type(options)[/^text\/html/]
    end

  end

end

%w{
murlsh
}.each { |m| require m }

module Murlsh

  # show the size of the url contents for some content types
  class UrlDisplayAdd55Size < Plugin

    @hook = 'url_display_add'

    # show the size of the url contents for some content types
    def self.run(markup, url, config)
      if url.content_length and url.content_type
        content_type_display = case url.content_type
          when 'application/pdf' then "#{human_bytes(url.content_length)} pdf"
          when 'audio/mpeg' then "#{human_bytes(url.content_length)} mp3"
          else ''
        end
        unless content_type_display.empty?
          markup.span(" (#{content_type_display})", :class => 'size')
        end
      end
    end

    # convert a number of bytes to human readable form
    def self.human_bytes(i)
      case i
        when 0..999 then  "#{i}B"
        when 1000..999999 then "#{i / 1000}k"
        when 1000000..999999999 then "#{i / 1000000}M"
        else "#{i / 1000000000}Gi"
      end
    end

  end

end

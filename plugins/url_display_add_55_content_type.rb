require 'murlsh'

module Murlsh

  # Warn of content types that launch external apps.
  class UrlDisplayAdd55ContentType < Plugin

    @hook = 'url_display_add'

    # Warn of content types that launch external apps.
    def self.run(markup, url, config)
      content_type_display = case url.content_type
        when 'application/pdf'; 'pdf'
        when 'audio/mpeg'; 'mp3'
        else ''
      end

      unless content_type_display.empty?
        markup.span " (#{content_type_display})", :class => 'content-type'
      end
    end

  end

end

module Murlsh

  # Append some content types to title to warn the user that they will launch
  # an external application.
  class AddPre65ContentTypeWarn < Plugin

    @hook = 'add_pre'

    def self.run(url, config)
      content_type_display = case url.content_type
        when 'application/ogg'; 'OGG'
        when 'application/pdf'; 'PDF'
        when 'audio/mpeg'; 'MP3'
        when 'audio/ogg'; 'OGG'
      end

      url.title << " (#{content_type_display})"  if content_type_display
    end

  end

end

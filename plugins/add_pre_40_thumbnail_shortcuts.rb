module Murlsh

  # Shortcuts for user-specified thumbnail urls.
  #
  # These keys can be passed in as the 'thumbnail' parameter when adding a url
  # and they will be converted to the corresponding url.
  class AddPre40ThumbnailShortcuts < Plugin

    @hook = 'add_pre'

    Shortcuts = {
      # 'trollin' => 'http://imagehost.com/trollface.jpg',
    }

    def self.run(url, config)
      if Shortcuts.key?(url.thumbnail_url)
        url.thumbnail_url = Shortcuts[url.thumbnail_url]
      end
    end

  end

end

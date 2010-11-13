require 'cgi'

require 'plumnailer'

require 'murlsh'

module Murlsh

  # Get thumbnail with plumnailer if not already set.
  class AddPre65DefaultThumb < Plugin

    @hook = 'add_pre'

    StorageDir = File.join(File.dirname(__FILE__), '..', 'public', 'img',
      'thumb')

    def self.run(url, config)
      unless url.thumbnail_url
        Murlsh::failproof do
          chooser = Plumnailer::Chooser.new
          choice = chooser.choose(url.url)

          if choice
            max_side = config.fetch('thumbnail_max_side', 90)
            choice.extend(Murlsh::ImageList).resize_down!(max_side)

            thumb_storage = Murlsh::ImgStore.new(StorageDir)

            stored_filename = thumb_storage.store_img(choice)
            url.thumbnail_url = "img/thumb/#{CGI.escape(stored_filename)}"
          end
        end
      end
    end

  end

end

require 'cgi'

require 'murlsh'

module Murlsh

  # Get thumbnail for image urls if not already set.
  class AddPre65ImgThumb < Plugin

    @hook = 'add_pre'

    StorageDir = File.join(File.dirname(__FILE__), '..', 'public', 'img',
      'thumb')

    ImageContentType = %w{
      image/gif
      image/jpeg
      image/png
      }

    def self.run(url, config)
      if not url.thumbnail_url and url.content_type and
        ImageContentType.include?(url.content_type)
        Murlsh::failproof do
          thumb_storage = Murlsh::ImgStore.new(StorageDir,
            :user_agent => config['user_agent'])

          stored_filename = thumb_storage.store_url(url.url) do |i|
            max_side = config.fetch('thumbnail_max_side', 90)
            i.extend(Murlsh::ImageList).resize_down!(max_side)
          end
          url.thumbnail_url = "img/thumb/#{CGI.escape(stored_filename)}"
        end
      end
    end

  end

end

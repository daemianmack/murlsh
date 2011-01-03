require 'cgi'

require 'murlsh'

module Murlsh

  # If the user has supplied a thumbnail url, adjust size and store it locally.
  class AddPre45SuppliedThumbnail < Plugin

    @hook = 'add_pre'

    StorageDir = File.join(File.dirname(__FILE__), '..', 'public', 'img',
      'thumb')

    def self.run(url, config)
      if url.thumbnail_url
        Murlsh::failproof do
          thumb_storage = Murlsh::ImgStore.new(StorageDir,
            :user_agent => config['user_agent'])

          stored_filename = thumb_storage.store_url(url.thumbnail_url) do |i|
            max_side = config.fetch('thumbnail_max_side', 90)
            i.extend(Murlsh::ImageList).resize_down!(max_side)
          end
          url.thumbnail_url = "img/thumb/#{CGI.escape(stored_filename)}"
        end
      end
    end

  end

end

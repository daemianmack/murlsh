require 'cgi'

require 'murlsh'

module Murlsh

  # Set the thumbnail of imageshack images.
  class AddPre60Imageshack < Plugin

    @hook = 'add_pre'

    ImageshackRe =
      %r{^http://img\d+\.imageshack\.us/img\d+/\d+/\w+\.(?:jpe?g|gif|png)$}i
    StorageDir = File.join(File.dirname(__FILE__), '..', 'public', 'img',
      'thumb')

    def self.run(url, config)
      if match = ImageshackRe.match(url.url)
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

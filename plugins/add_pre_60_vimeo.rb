require 'cgi'

require 'vimeo'

require 'murlsh'

module Murlsh

  # Set title and thumbnail url for Vimeo urls.
  class AddPre60Vimeo < Plugin

    @hook = 'add_pre'

    VimeoRe = %r{^http://(?:www\.)?vimeo\.com/(\d+)$}i
    StorageDir = File.join(File.dirname(__FILE__), '..', 'public', 'img',
      'thumb')

    def self.run(url, config)
      if id = url.url[VimeoRe, 1]
        info = Vimeo::Simple::Video.info(id)[0]

        unless url.user_supplied_title?
          url.title = "#{info['title']} by #{info['user_name']}"
        end

        thumb_storage = Murlsh::ImgStore.new(StorageDir,
          :user_agent => config['user_agent'])
        stored_filename = thumb_storage.store_url(info['thumbnail_small']) do |i|
          max_side = config.fetch('thumbnail_max_side', 90)
          i.extend(Murlsh::ImageList).resize_down!(max_side)
        end
        url.thumbnail_url = "img/thumb/#{CGI.escape(stored_filename)}"
      end
    end

  end

end

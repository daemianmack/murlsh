require 'cgi'

require 'murlsh'

module Murlsh

  # Set the thumbnail url for slideshare presentations.
  class AddPre60Slideshare < Plugin

    @hook = 'add_pre'

    SlideshareRe = %r{^http://www\.slideshare\.net/[0-9a-z-]+/[0-9a-z-]+$}i
    StorageDir = File.join(File.dirname(__FILE__), '..', 'public', 'img',
      'thumb')

    def self.run(url, config)
      if url.url[SlideshareRe]
        url.ask.doc.xpath_search("//meta[@rel='media:thumbnail']") do |node|
          if node and node['href']
            Murlsh::failproof do
              thumb_storage = Murlsh::ImgStore.new(StorageDir,
                :user_agent => config['user_agent'])

              stored_filename = thumb_storage.store_url(node['href']) do |i|
                max_side = config.fetch('thumbnail_max_side', 90)
                i.extend(Murlsh::ImageList).resize_down!(max_side)
              end
              url.thumbnail_url = "img/thumb/#{CGI.escape(stored_filename)}"
            end
          end
        end
      end
    end

  end

end

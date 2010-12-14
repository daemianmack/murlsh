require 'cgi'

require 'murlsh'

module Murlsh

  # If document has <meta rel="media:thumbnail"> use it as the thumbnail.
  class AddPre50MediaThumbnail < Plugin

    @hook = 'add_pre'

    StorageDir = File.join(File.dirname(__FILE__), '..', 'public', 'img',
      'thumb')

    def self.run(url, config)
      if not url.thumbnail_url and url.ask.doc
        url.ask.doc.xpath_search("//meta[@rel='media:thumbnail']") do |node|
          if node and node['href'] and not node['href'].empty?
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

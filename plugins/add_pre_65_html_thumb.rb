require 'cgi'

require 'plumnailer'

require 'murlsh'

module Murlsh

  # Get thumbnail for HTML page urls with plumnailer if not already set.
  class AddPre65HtmlThumb < Plugin

    @hook = 'add_pre'

    StorageDir = File.join(File.dirname(__FILE__), '..', 'public', 'img',
      'thumb')

    MarkupContentTypeRe = %r{^text/html|application/xhtml\+xml}

    def self.run(url, config)
      if not url.thumbnail_url and url.content_type and
        url.content_type[MarkupContentTypeRe]
        Murlsh::failproof do
          chooser = Plumnailer::Chooser.new
          choice = chooser.choose(url.url)

          if choice and choice.columns > 31 and choice.rows > 31
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

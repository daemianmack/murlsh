require 'flickraw'

require 'murlsh'

module Murlsh

  # Set the title of Flickr photos.
  class AddPre60Flickr < Plugin

    @hook = 'add_pre'

    FlickrRe = %r{^http://(?:www\.)?flickr\.com/photos/[@\w\-]+?/([\d]+)}i

    def self.run(url, config)
      unless url.user_supplied_title? or config['flickr_api_key'].to_s.empty?
        if photo_id = url.url[FlickrRe, 1]
          FlickRaw.api_key = config['flickr_api_key']
          info = flickr.photos.getInfo(:photo_id => photo_id)

          url.title = "#{info.title} by #{info.owner.username}"
        end
      end
    end

  end

end

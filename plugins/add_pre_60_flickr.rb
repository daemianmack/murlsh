%w{
cgi
flickraw

murlsh
}.each { |m| require m }

module Murlsh

  # Set the title and thumbnail url of Flickr photos.
  class AddPre60Flickr < Plugin

    @hook = 'add_pre'

    FlickrRe = %r{^http://(?:www\.)?flickr\.com/photos/[@\w\-]+?/([\d]+)}i

    def self.run(url, config)
      if config['flickr_api_key'] and not config['flickr_api_key'].empty?
        if photo_id = url.url[FlickrRe, 1]
          FlickRaw.api_key = config['flickr_api_key']
          info = flickr.photos.getInfo(:photo_id => photo_id)

          url.title = "#{info.title} by #{info.owner.username}"

          storage_dir = File.join(File.dirname(__FILE__), '..', 'public', 'img',
            'thumb')
          thumb_storage = Murlsh::ImgStore.new(storage_dir,
            :user_agent => config['user_agent'])
          stored_filename = thumb_storage.store(FlickRaw.url_s(info))
          url.thumbnail_url = "img/thumb/#{CGI.escape(stored_filename)}"
        end
      end
    end

  end

end

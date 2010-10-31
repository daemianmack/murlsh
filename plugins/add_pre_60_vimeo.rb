%w{
cgi

vimeo

murlsh
}.each { |m| require m }

module Murlsh

  # Set title and thumbnail url for Vimeo urls.
  class AddPre60Vimeo < Plugin

    @hook = 'add_pre'

    VimeoRe = %r{^http://(?:www\.)?vimeo\.com/(\d+)$}i

    def self.run(url, config)
      if id = url.url[VimeoRe, 1]
        info = Vimeo::Simple::Video.info(id)[0]

        url.title = "#{info['title']} by #{info['user_name']}"

        storage_dir = File.join(File.dirname(__FILE__), '..', 'public', 'img',
          'thumb')
        thumb_storage = Murlsh::ImgStore.new(storage_dir,
          :user_agent => config['user_agent'])
        stored_filename = thumb_storage.store(info['thumbnail_small'])
        url.thumbnail_url = "img/thumb/#{CGI.escape(stored_filename)}"
      end
    end

  end

end

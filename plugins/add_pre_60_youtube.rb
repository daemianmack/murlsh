%w{
cgi

murlsh
}.each { |m| require m }

module Murlsh

  # Add YouTube thumbnail.
  class AddPre60Youtube < Plugin

    @hook = 'add_pre'

    YoutubeRe =
      %r{^http://(?:(?:www|uk)\.)?youtube\.com/watch\?v=([\w\-]+)(?:&|$)}i

    def self.run(url, config)
      if youtube_id = url.url[YoutubeRe, 1]
        storage_dir = File.join(File.dirname(__FILE__), '..', 'public', 'img',
          'thumb')
        thumb_storage = Murlsh::ImgStore.new(storage_dir,
          :user_agent => config['user_agent'])
        stored_filename = thumb_storage.store(
          "http://img.youtube.com/vi/#{youtube_id}/default.jpg")
        url.thumbnail_url = "img/thumb/#{CGI.escape(stored_filename)}"
      end
    end

  end

end

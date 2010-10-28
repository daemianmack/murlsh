%w{
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
       url.thumbnail_url = "http://img.youtube.com/vi/#{youtube_id}/default.jpg"
      end
    end

  end

end

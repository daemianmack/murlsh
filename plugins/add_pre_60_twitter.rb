%w{
cgi

twitter

murlsh
}.each { |m| require m }

module Murlsh

  # Set title to entire tweet and set thumbnail url.
  class AddPre60Twitter < Plugin

    @hook = 'add_pre'

    TwitterRe = %r{^https?://twitter\.com/\w+/status(?:es)?/(\d+)$}i

    def self.run(url, config)
      if tweet_id = url.url[TwitterRe, 1]
        tweet = Twitter.status(tweet_id)

        url.title = "@#{tweet.user.screen_name}: #{tweet.text}"

        storage_dir = File.join(File.dirname(__FILE__), '..', 'public', 'img',
          'thumb')
        thumb_storage = Murlsh::ImgStore.new(storage_dir,
          :user_agent => config['user_agent'])
        stored_filename = thumb_storage.store(tweet.user.profile_image_url)
        url.thumbnail_url = "img/thumb/#{CGI.escape(stored_filename)}"
      end
    end

  end

end

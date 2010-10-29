%w{
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
        url.thumbnail_url = tweet.user.profile_image_url
      end
    end

  end

end

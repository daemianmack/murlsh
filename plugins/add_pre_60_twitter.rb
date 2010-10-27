%w{
open-uri

json

murlsh
}.each { |m| require m }

module Murlsh

  # Set title to entire tweet and set thumbnail url.
  class AddPre60Twitter < Plugin

    @hook = 'add_pre'

    TwitterRe = %r{^https?://twitter\.com/\w+/status(?:es)?/(\d+)$}i

    def self.run(url, config)
      if tweet_id = url.url[TwitterRe, 1]
        open("http://api.twitter.com/1/statuses/show/#{tweet_id}.json") do |f|
          json = JSON.parse(f.read)
          url.title = "@#{json['user']['screen_name']}: #{json['text']}"
          url.thumbnail_url = json['user']['profile_image_url']
        end
      end
    end

  end

end

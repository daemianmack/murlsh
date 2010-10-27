%w{
open-uri

json

murlsh
}.each { |m| require m }

module Murlsh

  # Use entire tweet for Twitter status url titles.
  class AddPre60TwitterTitle < Plugin

    @hook = 'add_pre'

    TwitterRe = %r{^https?://twitter\.com/\w+/status(?:es)?/(\d+)$}i

    def self.run(url, config)
      if tweet_id = url.url[TwitterRe, 1]
        open("http://api.twitter.com/1/statuses/show/#{tweet_id}.json") do |f|
          json = JSON.parse(f.read)
          url.title = "@#{json['user']['screen_name']}: #{json['text']}"
        end
      end
    end

  end

end

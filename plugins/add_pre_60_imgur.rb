%w{
murlsh
}.each { |m| require m }

module Murlsh

  # Add YouTube thumbnail.
  class AddPre60Imgur < Plugin

    @hook = 'add_pre'

    ImgurRe = %r{^(http://(?:i\.)?imgur\.com/)([a-z\d]+)(\.(?:jpe?g|gif|png))$}i

    def self.run(url, config)
      if match = ImgurRe.match(url.url)
        url.title = "imgur/#{match[2]}s#{match[3]}"
        url.thumbnail_url = "#{match[1]}#{match[2]}s#{match[3]}"
      end
    end

  end

end

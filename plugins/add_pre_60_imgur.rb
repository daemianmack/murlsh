require 'cgi'

require 'murlsh'

module Murlsh

  # Add YouTube thumbnail.
  class AddPre60Imgur < Plugin

    @hook = 'add_pre'

    ImgurRe = %r{^(http://(?:i\.)?imgur\.com/)([a-z\d]+)(\.(?:jpe?g|gif|png))$}i
    StorageDir = File.join(File.dirname(__FILE__), '..', 'public', 'img',
      'thumb')

    def self.run(url, config)
      if match = ImgurRe.match(url.url)
        url.title = "imgur/#{match[2]}s#{match[3]}"

        thumb_storage = Murlsh::ImgStore.new(StorageDir,
          :user_agent => config['user_agent'])
        stored_filename = thumb_storage.store_url(
          "#{match[1]}#{match[2]}s#{match[3]}")
        url.thumbnail_url = "img/thumb/#{CGI.escape(stored_filename)}"
      end
    end

  end

end

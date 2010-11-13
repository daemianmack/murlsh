require 'cgi'

require 'murlsh'

module Murlsh

  # Set the thumbnail of imageshack images.
  class AddPre60Imageshack < Plugin

    @hook = 'add_pre'

    ImageshackRe =
      %r{^(http://img\d+\.imageshack\.us/img\d+/\d+/)(\w+)\.(jpe?g|gif|png)$}i
    StorageDir = File.join(File.dirname(__FILE__), '..', 'public', 'img',
      'thumb')

    def self.run(url, config)
      if match = ImageshackRe.match(url.url)
        thumb_storage = Murlsh::ImgStore.new(StorageDir,
          :user_agent => config['user_agent'])
        stored_filename = thumb_storage.store_url(
          "#{match[1]}#{match[2]}.th.#{match[3]}")
        url.thumbnail_url = "img/thumb/#{CGI.escape(stored_filename)}"
      end
    end

  end

end

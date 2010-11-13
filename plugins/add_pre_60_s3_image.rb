require 'cgi'

require 'murlsh'

module Murlsh

  # Set the thumbnail of s3 hosted images.
  class AddPre60S3Image < Plugin

    @hook = 'add_pre'

    S3ImageRe = %r{^(http://static\.mmb\.s3\.amazonaws\.com/)([\w\-]+)\.(jpe?g|gif|pdf|png)$}i
    StorageDir = File.join(File.dirname(__FILE__), '..', 'public', 'img',
      'thumb')

    def self.run(url, config)
      if match = S3ImageRe.match(url.url)
        extension = match[3].downcase == 'pdf' ? 'png' : match[3]

        thumb_storage = Murlsh::ImgStore.new(StorageDir,
          :user_agent => config['user_agent'])
        stored_filename = thumb_storage.store_url(
          "#{match[1]}#{match[2]}.th.#{extension}")

        url.thumbnail_url = "img/thumb/#{CGI.escape(stored_filename)}"
        url.title = match[2]
      end
    end

  end

end

%w{
murlsh
}.each { |m| require m }

module Murlsh

  # Set the thumbnail of s3 hosted images.
  class AddPre60S3Image < Plugin

    @hook = 'add_pre'

    S3ImageRe = %r{^(http://static\.mmb\.s3\.amazonaws\.com/)([\w\-]+)\.(jpe?g|gif|pdf|png)$}i

    def self.run(url, config)
      if match = S3ImageRe.match(url.url)
        extension = match[3].downcase == 'pdf' ? 'png' : match[3]
        url.thumbnail_url = "#{match[1]}#{match[2]}.th.#{extension}"
        url.title = match[2]
      end
    end

  end

end

%w{
murlsh
}.each { |m| require m }

module Murlsh

  # Set the thumbnail of imageshack images.
  class AddPre60Imageshack < Plugin

    @hook = 'add_pre'

    ImageshackRe =
      %r{^(http://img\d+\.imageshack\.us/img\d+/\d+/)(\w+)\.(jpe?g|gif|png)$}i

    def self.run(url, config)
      if match = ImageshackRe.match(url.url)
        url.thumbnail_url = "#{match[1]}#{match[2]}.th.#{match[3]}"
      end
    end

  end

end

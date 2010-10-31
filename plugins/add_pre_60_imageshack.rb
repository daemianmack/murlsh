%w{
cgi

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
        storage_dir = File.join(File.dirname(__FILE__), '..', 'public', 'img',
          'thumb')
        thumb_storage = Murlsh::ImgStore.new(storage_dir,
          :user_agent => config['user_agent'])
        stored_filename = thumb_storage.store(
          "#{match[1]}#{match[2]}.th.#{match[3]}")
        url.thumbnail_url = "img/thumb/#{CGI.escape(stored_filename)}"
      end
    end

  end

end

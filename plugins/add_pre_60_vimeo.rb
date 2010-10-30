%w{
vimeo

murlsh
}.each { |m| require m }

module Murlsh

  # Set title and thumbnail url for Vimeo urls.
  class AddPre60Vimeo < Plugin

    @hook = 'add_pre'

    VimeoRe = %r{^http://(?:www\.)?vimeo\.com/(\d+)$}i

    def self.run(url, config)
      if id = url.url[VimeoRe, 1]
        info = Vimeo::Simple::Video.info(id)[0]

        url.title = "#{info['title']} by #{info['user_name']}"
        url.thumbnail_url = info['thumbnail_small']
      end
    end

  end

end

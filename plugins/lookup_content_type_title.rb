require 'murlsh'

module Murlsh

  # try to fetch the content type and title of a url
  class LookupContentTypeTitle < Plugin

    Hook = 'add_pre'

    def self.run(url, config)
      url.content_type = Murlsh.get_content_type(url.url)
      url.title = Murlsh.get_title(url.url, :content_type => url.content_type)
    end

  end

end

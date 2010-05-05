%w{
murlsh
}.each { |m| require m }

module Murlsh

  # try to fetch the content type and title of a url
  class AddPre50LookupContentTypeTitle < Plugin

    @hook = 'add_pre'

    def self.run(url, config)
      ask = URI(url.url).extend(Murlsh::UriAsk)
      url.content_type = ask.content_type
      url.title = ask.title
    end

  end

end

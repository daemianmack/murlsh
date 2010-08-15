%w{
murlsh
}.each { |m| require m }

module Murlsh

  # try to fetch the content type and title of a url
  class AddPre50LookupContentTypeTitle < Plugin

    @hook = 'add_pre'

    def self.run(url, config)
      ask = URI(url.url).extend(Murlsh::UriAsk)
      headers = {
        'User-Agent' =>
          "murlsh (http://github.com/mmb/murlsh) for #{config.fetch('root_url', '?')}"
      }
      url.content_type = ask.content_type(:headers => headers)
      url.title = ask.title(:headers => headers)
    end

  end

end

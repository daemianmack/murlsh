%w{
murlsh
}.each { |m| require m }

module Murlsh


  # Convert urls specifically for use on mobile devices into their non-mobile
  # equivalents.
  class AddPre40ConvertMobile < Plugin

    @hook = 'add_pre'

    TwitterRe = %r{^(http://)mobile\.(twitter\.com/.*)$}i
    WikipediaRe = %r{^(http://[a-z]+\.)m\.(wikipedia\.org/.*)$}i

    def self.run(url, config)
      url.url = case
        when match = TwitterRe.match(url.url)
          "#{match[1]}#{match[2]}"
        when match = WikipediaRe.match(url.url)
          "#{match[1]}#{match[2]}"
        else
          url.url
      end
    end

  end

end

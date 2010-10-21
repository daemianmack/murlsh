%w{
murlsh
}.each { |m| require m }

module Murlsh


  # Convert urls specifically for use on mobile devices into their non-mobile
  # equivalents.
  class AddPre40ConvertMobile < Plugin

    @hook = 'add_pre'

    WikipediaRe = %r{^(http://[a-z]+\.)m\.(wikipedia\.org/.*)$}

    def self.run(url, config)
      if match = WikipediaRe.match(url.url)
        url.url = "#{match[1]}#{match[2]}"
      end
    end

  end

end

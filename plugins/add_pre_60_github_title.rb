require 'uri'

require 'murlsh'

module Murlsh

  # Github project page titles are not very descriptive so add meta description
  # to title.
  class AddPre60GithubTitle < Plugin

    @hook = 'add_pre'

    GithubRe = %r{^https?://github\.com/\w+/[\w.-]+$}i

    def self.run(url, config)
      if url.url[GithubRe]
        ask = URI(url.url).extend(Murlsh::UriAsk)
        url.title << " - #{ask.description}"  unless ask.description.empty?
      end
    end

  end

end

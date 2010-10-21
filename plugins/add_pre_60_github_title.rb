%w{
murlsh
}.each { |m| require m }

module Murlsh

  # Github project page titles are not very descriptive so add meta description
  # to title.
  class AddPre60GithubTitle < Plugin

    @hook = 'add_pre'

    GitHubRe = %r{^http://github\.com/\w+/[\w.-]+$}

    def self.run(url, config)
      if url.url[GitHubRe]
        ask = URI(url.url).extend(Murlsh::UriAsk)
        url.title << " - #{ask.description}" unless ask.description.empty?
      end
    end

  end

end

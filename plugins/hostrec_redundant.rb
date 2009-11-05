module Murlsh

  # skip showing host record if domain is contained in title
  class HostrecRedundant < Plugin

    Hook = 'hostrec'

    def self.run(domain, url, title)
      domain unless (title and domain and title.downcase.index(domain))
    end

  end

end

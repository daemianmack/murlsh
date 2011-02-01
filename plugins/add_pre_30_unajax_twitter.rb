require 'murlsh'

module Murlsh

  # Convert Ajax friendly Twitter urls (with #!) into usable urls.
  class AddPre41UnajaxTwitter < Plugin

    @hook = 'add_pre'

    TwitterAjaxRe = %r{^(https?://twitter\.com/)#!/}i

    def self.run(url, config)
      url.url.sub!(TwitterAjaxRe, '\1')
      url.via.sub!(TwitterAjaxRe, '\1')  if url.via
    end

  end

end

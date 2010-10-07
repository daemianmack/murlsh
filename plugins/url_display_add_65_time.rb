%w{
murlsh
}.each { |m| require m }

module Murlsh

  # show the time the url was posted
  class UrlDisplayAdd65Time < Plugin

    @hook = 'url_display_add'

    # show the time the url was posted
    def self.run(markup, url, config)
      if url.time
        display_time = url.time.extend(Murlsh::TimeAgo).ago
        markup.span(", #{display_time}", :class => 'date')
      end
    end

  end

end

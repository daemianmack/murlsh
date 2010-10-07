%w{
uri

murlsh
}.each { |m| require m }

module Murlsh

  # show a via link for the url
  class UrlDisplayAdd60Via < Plugin

    @hook = 'url_display_add'

    # show a via link for the url
    def self.run(markup, url, config)
      if url.via
        if via_uri = Murlsh::failproof { URI(url.via) }
          via_uri_s = via_uri.to_s
          search = via_uri_s.gsub(%r{^http://}, '')

          display_via = case
            when m = search.match(%r{^news\.ycombinator\.com}i)
              'hacker news'
            when m = search.match(%r{^www\.reddit\.com/r/([a-z\d]+?)/}i)
              "#{m[1]}.reddit"
            when m = search.match(%r{^delicious\.com/(\w+)}i)
              "delicious/#{m[1]}"
            when m = search.match(%r{^twitter\.com/(\w+)}i)
              "twitter/#{m[1]}"
            when m = search.match(%r{^([a-z\d][a-z\d-]{0,61}[a-z\d])\.tumblr\.com/}i)
              "#{m[1]}.tumblr"
            else
              via_uri.domain || via_uri_s
          end

          markup.span(:class => 'via') do
            markup.text!(' via '); markup.a(display_via, :href => via_uri_s)
          end
        end
      end
    end

  end

end

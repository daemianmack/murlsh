%w{
murlsh
}.each { |m| require m }

module Murlsh

  # Convert a via url to its display text.
  #
  # For most urls the domain is displayed, but for some return custom text.
  class Via50Domain < Plugin

    @hook = 'via'

    def self.run(via)
      search = via.to_s.gsub(%r{^http://}, '')

      case
      when m = search.match(%r{^news\.ycombinator\.com}i)
        'hacker news'
      when m = search.match(%r{^www\.reddit\.com/r/([a-z\d]+?)/}i)
        "#{m[1]}.reddit"
      when m = search.match(%r{^delicious\.com/(\w+)}i)
        "delicious/#{m[1]}"
      when m = search.match(%r{^twitter\.com/(\w+)/?}i)
        "twitter/#{m[1]}"
      when m = search.match(%r{^([a-z\d][a-z\d-]{0,61}[a-z\d])\.tumblr\.com/}i)
        "#{m[1]}.tumblr"
      else
        via.domain || via
      end

    end

  end

end

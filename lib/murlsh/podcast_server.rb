require 'uri'

require 'rack'

require 'murlsh'

module Murlsh

  # Serve podcast RSS feed.
  class PodcastServer

    def initialize(config); @config = config; end

    # Respond to a GET request for podcast RSS feed.
    def get(req)
      conditions = ['content_type = ?', 'audio/mpeg']
      search_conditions = Murlsh::SearchConditions.new(req['q']).conditions
      unless search_conditions.empty?
        conditions[0] << " AND (#{search_conditions[0]})"
        conditions.push(*search_conditions[1..-1])
      end

      page = 1
      per_page = config.fetch('num_posts_feed', 25)

      result_set = Murlsh::UrlResultSet.new(conditions, page, per_page)
      urls = result_set.results

      feed_url = URI.join(config.fetch('root_url'), 'podcast.rss')
      body = Murlsh::RssBody.new(config, req, feed_url, urls)

      resp = Rack::Response.new(body, 200,
        'Cache-Control' => 'must-revalidate, max-age=0',
        'Content-Type' => 'application/rss+xml')
      if u = body.updated
        resp['Last-Modified'] = u.httpdate
      end
      resp
    end

    attr_reader :config
  end

end

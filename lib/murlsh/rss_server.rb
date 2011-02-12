require 'rack'

require 'murlsh'

module Murlsh

  # Serve RSS feed.
  class RssServer

    def initialize(config); @config = config; end

    # Respond to a GET request for RSS feed.
    def get(req)
      conditions = Murlsh::SearchConditions.new(req['q']).conditions
      page = 1
      per_page = config.fetch('num_posts_feed', 25)

      result_set = Murlsh::UrlResultSet.new(conditions, page, per_page)
      urls = result_set.results

      body = Murlsh::RssBody.new(config, req, urls)

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

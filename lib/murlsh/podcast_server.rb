require 'uri'

require 'rack'

require 'murlsh'

module Murlsh

  # Serve podcast RSS feed.
  class PodcastServer < Server

    # Respond to a GET request for podcast RSS feed.
    def get(req)
      page = 1
      per_page = config.fetch('num_posts_feed', 25)

      result_set = Murlsh::UrlResultSet.new(req['q'], page, per_page,
        :content_type => 'audio/mpeg')

      feed_url = URI.join(config.fetch('root_url'), 'podcast.rss')
      body = Murlsh::RssBody.new(config, req, feed_url, result_set.results)

      resp = Rack::Response.new(body, 200,
        'Content-Type' => 'application/rss+xml')
      if u = body.updated
        resp['Last-Modified'] = u.httpdate
      end
      resp
    end

  end

end

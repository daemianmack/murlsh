require 'uri'

require 'rack'

require 'murlsh'

module Murlsh

  # Serve m3u file of audio urls.
  class M3uServer

    AudioContentTypes = %w{
      application/ogg
      audio/mpeg
      audio/ogg
      }

    def initialize(config); @config = config; end

    # Respond to a GET request for m3u file.
    def get(req)
      conditions = ['content_type IN (?)', AudioContentTypes]
      search_conditions = Murlsh::SearchConditions.new(req['q']).conditions
      unless search_conditions.empty?
        conditions[0] << " AND (#{search_conditions[0]})"
        conditions.push(*search_conditions[1..-1])
      end

      page = 1
      per_page = config.fetch('num_posts_feed', 25)

      result_set = Murlsh::UrlResultSet.new(conditions, page, per_page)
      urls = result_set.results

      feed_url = URI.join(config['root_url'], 'm3u.m3u')
      body = Murlsh::M3uBody.new(config, req, feed_url, urls)

      resp = Rack::Response.new(body, 200,
        'Cache-Control' => 'must-revalidate, max-age=0',
        'Content-Type' => 'audio/x-mpegurl')
      if u = body.updated
        resp['Last-Modified'] = u.httpdate
      end
      resp
    end

    attr_reader :config
  end

end

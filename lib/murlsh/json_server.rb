require 'rack'

module Murlsh

  # Serve most recent urls in json and jsonp.
  class JsonServer

    def initialize(config); @config = config; end

    # Respond to a GET request. Return json of recent urls or jsonp if
    # if callback parameter is sent.
    def get(req)
      page = 1
      per_page = config.fetch('num_posts_feed', 25)

      result_set = Murlsh::UrlResultSet.new(req['q'], page, per_page)

      if req['callback']
        content_type = 'application/javascript'
        body = Murlsh::JsonpBody.new(config, req, result_set)
      else
        content_type = 'application/json'
        body = Murlsh::JsonBody.new(config, req, result_set)
      end

      Rack::Response.new body, 200,
        'Cache-Control' => 'must-revalidate, max-age=0',
        'Content-Type' => content_type
    end

    attr_reader :config
  end

end

require 'rack'

module Murlsh

  # Serve most recent urls in json.
  class JsonServer

    def initialize(config); @config = config; end

    # Respond to a GET request with json of recent urls.
    def get(req)
      page = 1
      per_page = config.fetch('num_posts_feed', 25)

      result_set = Murlsh::UrlResultSet.new(req['q'], page, per_page)

      body = Murlsh::JsonBody.new(config, req, result_set)

      Rack::Response.new body, 200, 'Content-Type' => 'application/json'
    end

    attr_reader :config
  end

end

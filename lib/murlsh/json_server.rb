require 'rack'

module Murlsh

  # Serve most recent urls in json and jsonp.
  class JsonServer

    include Murlsh::HeadFromGet

    def initialize(config); @config = config; end

    # Respond to a GET request. Return json of recent urls or jsonp if
    # if callback parameter is sent.
    def get(req)
      conditions = Murlsh::SearchConditions.new(req['q']).conditions
      page = 1
      per_page = @config.fetch('num_posts_feed', 25)

      result_set = Murlsh::UrlResultSet.new(conditions, page, per_page)

      resp = Rack::Response.new

      if req['callback']
        resp['Content-Type'] = 'application/javascript'
        resp.body = Murlsh::JsonpBody.new(@config, req, result_set)
      else
        resp['Content-Type'] = 'application/json'
        resp.body = Murlsh::JsonBody.new(@config, req, result_set)
      end

      resp['Cache-Control'] = 'must-revalidate, max-age=0'
      resp['ETag'] = "\"#{resp.body.md5}\""

      resp
    end

  end

end

require 'rack'

module Murlsh

  # Serve most recent urls in json and jsonp.
  class JsonServer

    include Murlsh::HeadFromGet

    def initialize(config); @config = config; end

    # Respond to a GET request. Return json of recent urls or jsonp if
    # if callback parameter is sent.
    def get(req)
      latest = Murlsh::Url.first(:order => 'time DESC')

      resp = Rack::Response.new

      resp['Cache-Control'] = 'must-revalidate, max-age=0'
      resp['ETag'] = "W/\"#{latest.time.to_i}#{req.params.sort}\""
      resp['Last-Modified'] = latest.time.httpdate

      if req['callback']
        resp['Content-Type'] = 'application/javascript'
        resp.body = Murlsh::JsonpBody.new(@config, req)
      else
        resp['Content-Type'] = 'application/json'
        resp.body = Murlsh::JsonBody.new(@config, req)
      end

      resp
    end

  end

end

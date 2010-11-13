require 'rack'
require 'rack/utils'

module Murlsh

  # Rack middleware to set a far future expires header for urls that match
  # patterns.
  class FarFutureExpires

    def initialize(app, options={})
      @app = app
      @patterns = options[:patterns] ? [*options[:patterns]] : []
      @future = options[:future] || 'Wed, 22 Jun 2019 20:07:00 GMT'
    end

    def call(env)
      status, headers, body = @app.call(env)

      req = Rack::Request.new(env)

      headers = Rack::Utils::HeaderHash.new(headers)

      @patterns.each do |pattern|
        if pattern.match(req.path)
          headers['Expires'] = @future
          break
        end
      end

      [status, headers, body]
    end

  end

end

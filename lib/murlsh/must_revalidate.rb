%w{
rack/utils
}.each { |m| require m }

module Murlsh

  # Rack middleware to force caches to always revalidate for urls that match
  # patterns.
  class MustRevalidate

    def initialize(app, options={})
      @app = app
      @patterns = options[:patterns] ? [*options[:patterns]] : []
    end

    def call(env)
      status, headers, body = @app.call(env)

      headers = Rack::Utils::HeaderHash.new(headers)

      @patterns.each do |pattern|
        if pattern.match(env['REQUEST_PATH'])
          headers['Cache-Control'] = 'must-revalidate, max-age=0'
          break
        end
      end

      [status, headers, body]
    end

  end

end

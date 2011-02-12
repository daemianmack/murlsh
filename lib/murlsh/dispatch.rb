require 'uri'

require 'active_record'
require 'rack'

require 'murlsh'

module Murlsh

  # Dispatch requests.
  class Dispatch

    # Set up database connection and dispatch table.
    def initialize(config)
      @config = config

      atom_server = Murlsh::AtomServer.new(config)
      json_server = Murlsh::JsonServer.new(config)
      pop_server = Murlsh::PopServer.new(config)
      random_server = Murlsh::RandomServer.new(config)
      url_server = Murlsh::UrlServer.new(config)

      root_path = URI(config.fetch('root_url')).path

      @routes = [
        [%r{^(?:HEAD|GET) #{root_path}atom\.atom$}, atom_server.method(:get)],
        [%r{^(?:HEAD|GET) #{root_path}json\.json$}, json_server.method(:get)],
        [%r{^POST #{root_path}pop$}, pop_server.method(:post)],
        [%r{^(?:HEAD|GET) #{root_path}random$}, random_server.method(:get)],
        [%r{^(?:HEAD|GET) #{root_path}(url)?$}, url_server.method(:get)],
        [%r{^POST #{root_path}(url)?$}, url_server.method(:post)],
      ]

      db_init
    end

    def db_init
      ActiveRecord::Base.establish_connection(
        :adapter => 'sqlite3', :database => @config.fetch('db_file'))

      ActiveRecord::Base.default_timezone = :utc
      ActiveRecord::Base.include_root_in_json = false
      # ActiveRecord::Base.logger = Logger.new(STDERR)
    end

    # Figure out which method will handle request.
    def dispatch(req)
      method_match = routes.find do |rule|
        rule[0].match("#{req.request_method} #{req.path}")
      end

      method_match ? method_match[1] : self.method(:not_found)
    end

    # Rack call.
    def call(env)
      req = Rack::Request.new(env)
      dispatch(req).call(req).finish
    end

    # Called if the request is not found.
    def not_found(req)
      if req.head?
        Rack::Response.new [], 404
      else
        Rack::Response.new "<p>#{req.url} not found</p>

<p><a href=\"#{@config['root_url']}\">root<a></p>
",
          404, { 'Content-Type' => 'text/html' }
      end
    end

    attr_accessor :routes
  end

end

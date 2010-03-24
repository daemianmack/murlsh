%w{
active_record
rack

murlsh
}.each { |m| require m }

module Murlsh

  # Dispatch requests.
  class Dispatch

    # Set up config hash and database connection.
    def initialize(config)
      @config = config
      @url_root = URI(@config.fetch('root_url')).path

      ActiveRecord::Base.establish_connection(
        :adapter => 'sqlite3', :database => @config.fetch('db_file'))

      @db = ActiveRecord::Base.connection.instance_variable_get(:@connection)

      @url_server = Murlsh::UrlServer.new(@config, @db)
    end

    # Rack call.
    def call(env)
      url_url = "#{@url_root}url"

      dispatch = {
        ['GET', @url_root] => @url_server.method(:get),
        ['POST', @url_root] => @url_server.method(:post),
        ['GET', url_url] => @url_server.method(:get),
        ['POST', url_url] => @url_server.method(:post),
      }
      dispatch.default = self.method(:not_found)

      req = Rack::Request.new(env)

      dispatch[[req.request_method, req.path]].call(req).finish
    end

    # Called if the request is not found.
    def not_found(req)
      Rack::Response.new("<p>#{req.url} not found</p>

<p><a href=\"#{@config['root_url']}\">root<a></p>
",
        404, { 'Content-Type' => 'text/html' })
    end

  end

end

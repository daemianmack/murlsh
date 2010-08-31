%w{
active_record
rack

murlsh
}.each { |m| require m }

module Murlsh

  # Dispatch requests.
  class Dispatch

    # Set up database connection and dispatch table.
    def initialize(config)
      @config = config

      ActiveRecord::Base.establish_connection(
        :adapter => 'sqlite3', :database => @config.fetch('db_file'))
      ActiveRecord::Base.include_root_in_json = false

      db = ActiveRecord::Base.connection.instance_variable_get(:@connection)

      url_server = Murlsh::UrlServer.new(@config, db)
      config_server = Murlsh::ConfigServer.new(@config)
      flickr_server = Murlsh::FlickrServer.new(@config)
      twitter_server = Murlsh::TwitterServer.new

      root_path = URI(@config.fetch('root_url')).path

      @dispatch = [
        [%r{^HEAD #{root_path}(url)?$}, url_server.method(:head)],
        [%r{^GET #{root_path}(url)?$}, url_server.method(:get)],
        [%r{^POST #{root_path}(url)?$}, url_server.method(:post)],
        [%r{^HEAD #{root_path}config$}, config_server.method(:head)],
        [%r{^GET #{root_path}config$}, config_server.method(:get)],
        [%r{^HEAD #{root_path}flickr$}, flickr_server.method(:head)],
        [%r{^GET #{root_path}flickr$}, flickr_server.method(:get)],
        [%r{^HEAD #{root_path}twitter/.+$}, twitter_server.method(:head)],
        [%r{^GET #{root_path}twitter/.+$}, twitter_server.method(:get)],
      ]
    end

    # Figure out which method will handle request.
    def dispatch(req)
      method_match = @dispatch.find do |rule|
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
      Rack::Response.new("<p>#{req.url} not found</p>

<p><a href=\"#{@config['root_url']}\">root<a></p>
",
        404, { 'Content-Type' => 'text/html' })
    end

  end

end

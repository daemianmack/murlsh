%w{
murlsh

rubygems
active_record
rack
sqlite3

yaml
}.each { |m| require m }

module Murlsh

  class Dispatch

    def initialize
      @config = YAML.load_file('config.yaml')
      @url_root = URI(@config.fetch('root_url')).path

      ActiveRecord::Base.establish_connection(
        :adapter => 'sqlite3', :database => @config.fetch('db_file'))

      @db = ActiveRecord::Base.connection.instance_variable_get(:@connection)
      @db.create_function('MATCH', 2) do |func,search_in,search_for|
        func.result = search_in.to_s.match(/#{search_for}/i) ? 1 : nil
      end

      @url_server = Murlsh::UrlServer.new(@config, @db)
    end

    def call(env)
      dispatch = {
        ['GET', @url_root] => [@url_server, :get],
        ['POST', @url_root] => [@url_server, :post],
        ['GET', "#{@url_root}url"] => [@url_server, :get],
        ['POST', "#{@url_root}url"] => [@url_server, :post],
      }
      dispatch.default = [self, :not_found]

      req = Rack::Request.new(env)

      obj, meth = dispatch[[req.request_method, req.path]]

      obj.send(meth, req).finish
    end

    def not_found(req)
      Rack::Response.new("<p>#{req.url} not found</p>

<p><a href=\"#{@config['root_url']}\">root<a></p>
",
        404, { 'Content-Type' => 'text/html' })
    end

  end

end

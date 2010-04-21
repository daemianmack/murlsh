%w{
active_record
rack
}.each { |m| require m }

module Murlsh

  # Build responses for HTTP requests.
  class UrlServer

    def initialize(config, db)
      @config, @db = config, db
      ActiveRecord::Base.default_timezone = :utc

      Dir['plugins/*.rb'].each { |p| load p }
    end

    # Respond to a GET request. Return a page of urls based on the query
    # string parameters.
    def get(req)
      resp = Murlsh::XhtmlResponse.new

      resp.set_content_type(req.env['HTTP_ACCEPT'], req.env['HTTP_USER_AGENT'])

      last_db_update = File::Stat.new(@config['db_file']).mtime
      resp['Cache-Control'] = 'must-revalidate, max-age=0'
      resp['ETag'] = "W/\"#{last_db_update.to_i}#{req.params.sort}\""
      resp['Last-Modified'] = last_db_update.httpdate

      resp.body = Murlsh::UrlBody.new(@config, @db, req)

      resp
    end

    # Respond to a POST request. Add the new url and return json.
    def post(req)
      unless req.params['url'].empty?
        auth = req.params['auth']
        if user = auth.empty? ? nil : Murlsh::Auth.new(
          @config.fetch('auth_file')).auth(auth)
          ActiveRecord::Base.establish_connection(:adapter => 'sqlite3',
            :database => @config.fetch('db_file'))

          mu = Murlsh::Url.new do |u|
            u.time = Time.now.gmtime
            u.url = req.params['url']
            u.email = user[:email]
            u.name = user[:name]
            u.via = req.params['via'] unless (req.params['via'] || []).empty?
          end

          Murlsh::Plugin.hooks('add_pre') { |p| p.run(mu, @config) }

          mu.save

          Murlsh::Plugin.hooks('add_post') { |p| p.run(@config) }

          resp = Rack::Response.new([mu].to_json, 200, {
            'Content-Type' => 'application/json' })

          resp
        else
          Rack::Response.new('Permission denied', 403, {
            'Content-Type' => 'text/plain' })
        end
      else
        Rack::Response.new('No url', 500, { 'Content-Type' => 'text/plain' })
      end
    end

  end

end

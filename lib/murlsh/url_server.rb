%w{
rubygems
active_record
rack
}.each { |m| require m }

module Murlsh

  # Build responses for HTTP requests.
  class UrlServer

    def initialize(config, db)
      @config = config
      @db = db
      ActiveRecord::Base.default_timezone = :utc

      Dir['plugins/*.rb'].each { |p| load p }
    end

    # Respond to a GET request. Return a page of urls based on the query
    # string parameters.
    def get(req)
      resp = Murlsh::XhtmlResponse.new

      resp.set_content_type(req.env['HTTP_ACCEPT'], req.env['HTTP_USER_AGENT'])

      last_db_update = File::Stat.new(@config['db_file']).mtime
      resp['Last-Modified'] = last_db_update.httpdate
      resp['ETag'] = "#{last_db_update.to_i}#{req.params.sort}"

      resp.body = Murlsh::UrlBody.new(@config, @db, req)

      resp
    end

    # Respond to a POST request. Add the new url and return json.
    def post(req)
      resp = Rack::Response.new

      url = req.params['url']

      unless url.empty?
        auth = req.params['auth']
        if user = auth.empty? ? nil : Murlsh::Auth.new(
          @config.fetch('auth_file')).auth(auth)
          ActiveRecord::Base.establish_connection(:adapter => 'sqlite3',
            :database => @config.fetch('db_file'))

          mu = Murlsh::Url.new do |u|
            u.time = Time.now.gmtime
            u.url = url
            u.email = user[:email]
            u.name = user[:name]
          end

          Murlsh::Plugin.hooks('add_pre') { |p| p.run(mu, @config) }

          mu.save

          Murlsh::Plugin.hooks('add_post') { |p| p.run(@config) }

          resp['Content-Type'] = 'application/json'

          resp.set_cookie('auth',
            :expires => Time.mktime(2015, 6, 22),
            :path => '/',
            :value => auth)

          resp.body = [mu].to_json
        else
          resp.status = 403
          resp['Content-Type'] = 'text/plain'
          resp.write('Permission denied')
        end
      else
        resp.status = 500
        resp['Content-Type'] = 'text/plain'
        resp.write('No url')
      end
      resp
    end

  end

end

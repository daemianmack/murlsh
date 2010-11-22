require 'active_record'
require 'rack'

module Murlsh

  # Build responses for HTTP requests.
  class UrlServer

    include HeadFromGet

    def initialize(config, db)
      @config, @db = config, db
      ActiveRecord::Base.default_timezone = :utc

      Dir['plugins/*.rb'].each { |p| require p }
    end

    # Respond to a GET request. Return a page of urls based on the query
    # string parameters.
    def get(req)
      last_db_update = File::Stat.new(@config['db_file']).mtime

      resp = Rack::Response.new

      resp['Cache-Control'] = 'must-revalidate, max-age=0'
      resp['Content-Type'] = 'text/html; charset=utf-8'
      resp['ETag'] = "W/\"#{last_db_update.to_i}#{req.params.sort}\""
      resp['Last-Modified'] = last_db_update.httpdate

      resp.body = Murlsh::UrlBody.new(@config, @db, req, resp['Content-Type'])

      resp
    end

    # Respond to a POST request. Add the new url and return json.
    def post(req)
      auth = req.params['auth']
      if user = auth.empty? ? nil : Murlsh::Auth.new(
        @config.fetch('auth_file')).auth(auth)
        ActiveRecord::Base.establish_connection :adapter => 'sqlite3',
          :database => @config.fetch('db_file')

        mu = Murlsh::Url.new do |u|
          u.time = Time.now.gmtime
          u.url = req.params['url']
          u.email = user[:email]
          u.name = user[:name]
          u.via = req.params['via']  unless (req.params['via'] || []).empty?
        end

        begin
          # validate before add_pre plugins have run and also after (in save!)
          raise ActiveRecord::RecordInvalid.new(mu)  unless mu.valid?
          Murlsh::Plugin.hooks('add_pre') { |p| p.run mu, @config }
          mu.save!
          Murlsh::Plugin.hooks('add_post') { |p| p.run mu, @config }
          response_body, response_code = [mu], 200
        rescue ActiveRecord::RecordInvalid => error
          response_body = {
            'url' => error.record,
            'errors' => error.record.errors,
            }
          response_code = 500
        end
      else
        response_body, response_code = '', 403
      end

      Rack::Response.new(response_body.to_json, response_code, {
        'Content-Type' => 'application/json' })
    end

  end

end

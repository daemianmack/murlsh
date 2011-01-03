require 'time'

require 'active_record'
require 'rack'

module Murlsh

  # Build responses for HTTP requests.
  class UrlServer

    include HeadFromGet

    def initialize(config); @config = config; end

    # Respond to a GET request. Return a page of urls based on the query
    # string parameters.
    def get(req)
      conditions = Murlsh::SearchConditions.new(req['q']).conditions
      page = [req['p'].to_i, 1].max
      per_page = req['pp'] ? req['pp'].to_i :
        @config.fetch('num_posts_page', 25)

      result_set = Murlsh::UrlResultSet.new(conditions, page, per_page)

      last_update = result_set.last_update

      resp = Rack::Response.new

      resp['Cache-Control'] = 'must-revalidate, max-age=0'
      resp['Content-Type'] = 'text/html; charset=utf-8'
      resp['ETag'] = "W/\"#{last_update.to_i}#{req.params.sort.join}\""
      resp['Last-Modified'] = last_update.httpdate  if last_update

      resp.body = Murlsh::UrlBody.new(@config, req, result_set,
        resp['Content-Type'])

      resp
    end

    # Respond to a POST request. Add the new url and return json.
    def post(req)
      auth = req['auth']
      if user = auth.empty? ? nil : Murlsh::Auth.new(
        @config.fetch('auth_file')).auth(auth)

        mu = Murlsh::Url.new do |u|
          u.url = req['url']
          u.email = user[:email]
          u.name = user[:name]

          # optional parameters
          unless req['thumbnail'].to_s.empty?
            u.thumbnail_url = req['thumbnail']
          end

          u.time = if req['time']
            Time.at(req['time'].to_f).utc
          else
            Time.now.utc
          end

          unless req['title'].to_s.empty?
            u.title = req['title']
            u.user_supplied_title = true
          end

          u.via = req['via']  unless req['via'].to_s.empty?
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

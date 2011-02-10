require 'active_record'
require 'rack'

module Murlsh

  # Build responses for HTTP requests.
  class UrlServer

    def initialize(config); @config = config; end

    # Respond to a GET request. Return a page of urls based on the query
    # string parameters.
    def get(req)
      conditions = Murlsh::SearchConditions.new(req['q']).conditions
      page = [req['p'].to_i, 1].max
      per_page = req['pp'] ? req['pp'].to_i :
        config.fetch('num_posts_page', 25)

      content_type = 'text/html; charset=utf-8'
      result_set = Murlsh::UrlResultSet.new(conditions, page, per_page)

      body = Murlsh::UrlBody.new(config, req, result_set, content_type)

      resp = Rack::Response.new
      resp.write(body.build)
      resp['Cache-Control'] = 'must-revalidate, max-age=0'
      resp['Content-Type'] = content_type

      resp
    end

    # Respond to a POST request. Add the new url and return json.
    def post(req)
      if user = auth_from_req(req)
        mu = Murlsh::Url.new do |u|
          u.url = req['url']
          u.email = user[:email]
          u.name = user[:name]

          # optional parameters
          unless req['thumbnail'].to_s.empty?
            if thumbnail_url = config.fetch('thumbnail_shortcuts', {})[req[
              'thumbnail']]
              u.thumbnail_url = thumbnail_url
            else
              u.thumbnail_url = req['thumbnail']
            end
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
          Murlsh::Plugin.hooks('add_pre') { |p| p.run mu, config }
          mu.save!
          Murlsh::Plugin.hooks('add_post') { |p| p.run mu, config }
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

    # Authorize a user from a request.
    def auth_from_req(req)
      secret = req['auth']
 
      secret.to_s.empty? ? nil : Murlsh::Auth.new(
        config['auth_file']).auth(secret)
    end

    attr_reader :config
  end

end

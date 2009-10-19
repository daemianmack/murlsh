%w{
rubygems
active_record
rack
}.each { |m| require m }

module Murlsh

  class UrlServer

    def initialize(config, db)
      @config = config
      @db = db
      ActiveRecord::Base.default_timezone = :utc
    end

    def get(req)
      resp = Murlsh::XhtmlResponse.new

      resp.set_content_type(req.env['HTTP_ACCEPT'], req.env['HTTP_USER_AGENT'])

      last_db_update = File::Stat.new(@config['db_file']).mtime
      resp['Last-Modified'] = last_db_update.httpdate
      resp['ETag'] = "#{last_db_update.to_i}#{req.params.sort}"

      resp.body = Murlsh::UrlBody.new(@config, @db, req)

      resp
    end

    def post(req)
      resp = Rack::Response.new

      url = req.params['url']

      unless url.empty?
        auth = req.params['auth']
        if user = auth.empty? ? nil : Murlsh::Auth.new(
          @config.fetch('auth_file')).auth(auth)
          ActiveRecord::Base.establish_connection(:adapter => 'sqlite3',
            :database => @config.fetch('db_file'))

          content_type = Murlsh.get_content_type(url)
          mu = Murlsh::Url.new do |u|
            u.time = Time.now.gmtime
            u.url = url
            u.email = user[:email]
            u.name = user[:name]
            u.title = Murlsh.get_title(url, :content_type => content_type)
            u.content_type = content_type
          end

          mu.save

          result = Murlsh::Url.all(:order => 'id DESC',
            :limit => @config.fetch('num_posts_feed', 25))

          feed = Murlsh::AtomFeed.new(@config.fetch('root_url'),
            :filename => @config.fetch('feed_file'),
            :title => @config.fetch('page_title', ''))

          feed.write(result, @config.fetch('feed_file'))

          resp['Content-Type'] = 'application/json'

          resp.set_cookie('auth',
            :expires => Time.mktime(2015, 6, 22),
            :path => '/',
            :value => auth)

          resp.body = result[0,1].to_json
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

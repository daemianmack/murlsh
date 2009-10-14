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

      urls = Murlsh::Url.all(:conditions => search_conditions(req.params['q']),
        :order => 'id DESC',
        :limit =>  req.params['n'] ? req.params['n'].to_i :
        @config.fetch('num_posts_page', 100))

      resp['Last-Modified'] = urls.first.time.httpdate unless urls.empty?

      resp.body = Murlsh::UrlBody.new(@config, @db, req, urls)

      resp
    end

    def search_conditions(q)
      if q
        search_cols = %w{name title url}
        [search_cols.collect { |x| "MATCH(#{x}, ?)" }.join(' OR ')].push(
          *[q] * search_cols.size)
      else
        []
      end
    end

    def post(req)
      resp = Rack::Response.new

      unless req.params['url'].empty?
        user = nil
        unless req.params['auth'].empty?
          user = Murlsh::Auth.new(@config.fetch('auth_file')).auth(
            req.params['auth'])
        end

        if user
          ActiveRecord::Base.establish_connection(:adapter => 'sqlite3',
            :database => @config.fetch('db_file'))

          content_type = Murlsh.get_content_type(req.params['url'])
          mu = Murlsh::Url.new do |u|
            u.time = Time.now.gmtime
            u.url = req.params['url']
            u.email = user[:email]
            u.name = user[:name]
            u.title = Murlsh.get_title(req.params['url'],
              :content_type => content_type)
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
            :value => req.params['auth'])

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

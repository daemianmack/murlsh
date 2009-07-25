%w{
murlsh

rubygems
active_record
rack
}.each { |m| require m }

module Murlsh

  class UrlServer

    def initialize(config, db)
      @config = config
      @db = db
    end

    def get(req)
      resp = Rack::Response.new

      resp['Content-Type'] = Murlsh.xhtml_content_type(
        req.env['HTTP_ACCEPT'], req.env['HTTP_USER_AGENT'])

      xm = Murlsh::Markup.new(:indent => 2)
      xm.instruct! :xml
      xm.declare! :DOCTYPE, :html, :PUBLIC, '-//W3C//DTD XHTML 1.1//EN',
        'http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd'

      resp.body = xm.html(:xmlns => 'http://www.w3.org/1999/xhtml',
        :'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
        :'xsi:schemaLocation' => 'http://www.w3.org/MarkUp/SCHEMA/xhtml11.xsd',
        :'xml:lang' => 'en') {
        xm.head {
          xm.title(@config.fetch('page_title', '') +
            (req.params['q'] ? " /#{req.params['q']}" : ''))
          xm.metas(
            :description => @config.fetch('description', ''),
            :viewport =>
              'width=device-width,minimum-scale=1.0,maximum-scale=1.0')
          (gv = @config.fetch('google_verify')) and xm.metas('verify-v1' => gv)
          xm.css(@config.fetch('css_files', []),
            :prefix => @config.fetch('css_prefix', ''))
          xm.css('phone.css',
            :media => 'only screen and (max-device-width: 480px)',
            :prefix => @config.fetch('css_prefix', ''))
          xm.atom(@config.fetch('feed_file'))
        }
        xm.body {
          xm.div(:id => 'closer') { }
          xm.ul(:id => 'urls') {

            xm.li {
              xm.div(:class => 'icon') {
                xm.a('feed', :href => @config.fetch('feed_file'),
                  :class => 'feed')
              }
              xm.form(:action => '', :method => 'get') {
                value = req.params['q']
                Murlsh::Referrer.new(req.referrer).search_query do |refq|
                  re_parts = refq.split.collect { |x| Regexp.escape(x) }
                  value = "\\b(#{re_parts.join('|')})\\b"
                end
                xm.fieldset {
                  xm.input(:type => 'text', :id => 'q', :name => 'q',
                    :size => 32, :value => value)
                  xm.input(:type => 'submit', :value=> 'Regex Search')
                }
              }
            }

            conditions = []
            if req.params['q']
              search_cols = %w{name title url}
              conditions = [search_cols.collect { |x| "MATCH(#{x}, ?)" }.join(
                ' OR ')].push(*[req.params['q']] * search_cols.size)
            end

            last = nil
            author_group = 1

            Murlsh::Url.all(:conditions => conditions, :order => 'id DESC',
              :limit =>  req.params['n'] ? req.params['n'].to_i :
                @config.fetch('num_posts_page', 100)
              ).each do |mu|
              first_class = ''
              unless mu.same_author?(last)
                author_group = (author_group + 1) % 2
                first_class = ' author_first' 
              end

              xm.li(:class => "author_group_#{author_group}#{first_class}") {
                unless mu.same_author?(last)
                  gravatar_size = @config.fetch('gravatar_size', 0)
                  xm.div(:class => 'icon') {
                    xm.gravatar(mu.email, 's' => gravatar_size,
                      :text => mu.name)
                  } if mu.email and gravatar_size > 0
                  xm.div(mu.name, :class => 'name') if mu.name
                end

                xm.a(mu.title.strip.gsub(/\s+/, ' '), :href => mu.url)

                mu.hostrec { |hostrec| xm.span(hostrec, :class => 'host') }
                last = mu
              }
            end

            xm.li {
              xm.form(:action => '', :method => 'post') {
                xm.fieldset(:id => 'add') {
                  xm.p {
                    xm.label('Add URL:', :for => 'url')
                    xm.input(:type => 'text', :id => 'url', :name => 'url',
                      :size => 32)
                  }
                  xm.p {
                    xm.label('Password:', :for => 'auth')
                    xm.input(:type => 'password', :id => 'auth',
                      :name => 'auth', :size => 16)
                    xm.input(:type => 'button', :id => 'submit',
                      :value => 'Add')
                  }
                }
              }
            }
          }

          xm.div(:style => 'clear : both')

          xm.p {
            xm.text! 'powered by '
            xm.a('murlsh', :href => 'http://github.com/mmb/murlsh/')
          }
          xm.javascript(%w{jquery-1.3.2.min.js jquery.cookie.js
            jquery.corner.js js.js}, :prefix => @config.fetch('js_prefix', ''))
        }
      }
      resp
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
          ActiveRecord::Base.default_timezone = :utc
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

          open(@config.fetch('feed_file'), 'w') do |f|
            f.flock File::LOCK_EX

            feed = Murlsh::AtomFeed.new(@config.fetch('root_url'),
              :filename => @config.fetch('feed_file'),
              :title => @config.fetch('page_title', ''))

            feed.make(result, :target => f)

            f.flock File::LOCK_UN
          end

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

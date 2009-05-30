#!/usr/bin/ruby
$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'murlsh'

require 'rubygems'
require 'active_record'
require 'builder'
require 'sqlite3'

require 'cgi'
require 'time'
require 'uri'
require 'yaml'

config = YAML.load_file('config.yaml')

cgi = CGI.new

headers = { 'status' => 'SERVER_ERROR' }
body = ''

if cgi.request_method == 'POST'
  unless cgi['url'].empty?
    user = nil
    unless cgi['auth'].empty?
      require 'bcrypt'
      require 'csv'
      CSV::Reader.parse(File.open(config['auth_file'])) do |row|
        if BCrypt::Password.new(row[2]) == cgi['auth']
          user = { :name => row[0], :email => row[1] }
          break
        end
      end
    end

    if user
      ActiveRecord::Base.default_timezone = :utc
      ActiveRecord::Base.establish_connection(
        :adapter => 'sqlite3', :database => config['db_file'])

      mu = Murlsh::Url.new do |u|
        u.time = Time.now.gmtime
        u.url = cgi['url']
        u.email = user[:email]
        u.name = user[:name]
        u.title = Murlsh.get_title(cgi['url'])
      end

      mu.save

      result = Murlsh::Url.all(:order => 'id DESC',
        :limit => config['num_posts_feed'])

      open(config['feed_file'], 'w') do |f|
        f.flock File::LOCK_EX

        xm = Builder::XmlMarkup.new(:target => f)
        xm.instruct! :xml

        xm.feed(:xmlns => 'http://www.w3.org/2005/Atom') {
          xm.id(config['root_url'])
          xm.link(:href => "#{config['root_url']}#{config['feed_file']}",
            :rel => 'self')
          xm.title(config['page_title'])
          xm.updated(result.collect { |mu| mu.time }.max.xmlschema)
          uri_parsed = URI.parse(config['root_url'])
          host, domain = uri_parsed.host.match(
            /^(.*?)\.?([^.]+\.[^.]+)$/).captures
          result.each do |mu|
            xm.entry {
              xm.author { xm.name(mu.name) }
              xm.title(mu.title)
              xm.id("tag:#{domain},#{mu.time.strftime('%Y-%m-%d')}:#{host}#{uri_parsed.path}#{mu.id}")
              xm.summary(mu.title)
              xm.updated(mu.time.xmlschema)
              xm.link(:href => mu.url)
            }
          end
        }

        f.flock File::LOCK_UN
      end

      headers.update(
        'cookie' => [CGI::Cookie::new(
          'expires' => Time.mktime(2015, 6, 22),
          'name' => 'auth',
          'path' => '/',
          'value' => cgi['auth'])],
        'status' => 'OK',
        'type' => 'application/json')

      body = result[0,1].to_json
    else
      headers.update({ 'status' => 'FORBIDDEN', 'type' => 'text/plain' })
      body = 'Permission denied'
    end
  else
    headers['type'] = 'text/plain'
    body = 'No url'
  end
else
  headers.update('status' => 'MOVED', 'Location' => config['root_url'])
end

cgi.out(headers) { body }

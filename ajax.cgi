#!/usr/bin/ruby
$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'murlsh'

require 'rubygems'
require 'active_record'
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
      user = Murlsh::Auth.new(config.fetch('auth_file')).auth(cgi['auth'])
    end

    if user
      ActiveRecord::Base.default_timezone = :utc
      ActiveRecord::Base.establish_connection(
        :adapter => 'sqlite3', :database => config.fetch('db_file'))

      content_type = Murlsh.get_content_type(cgi['url'])
      mu = Murlsh::Url.new do |u|
        u.time = Time.now.gmtime
        u.url = cgi['url']
        u.email = user[:email]
        u.name = user[:name]
        u.title = Murlsh.get_title(cgi['url'], :content_type => content_type)
        u.content_type = content_type
      end

      mu.save

      result = Murlsh::Url.all(:order => 'id DESC',
        :limit => config.fetch('num_posts_feed', 25))

      open(config.fetch('feed_file'), 'w') do |f|
        f.flock File::LOCK_EX

        feed = Murlsh::AtomFeed.new(config.fetch('root_url'),
          :filename => config.fetch('feed_file'),
          :title => config.fetch('page_title', ''))

        feed.make(result, :target => f)

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
  headers.update('status' => 'MOVED', 'Location' => config.fetch('root_url'))
end

cgi.out(headers) { body }

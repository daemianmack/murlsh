#!/usr/bin/ruby
require 'cgi'
require 'json'
require 'uri'

require 'rubygems'
require 'builder'
require 'sqlite3'

config = {
  'auth_file' => '/home/mm6/murlsh_users', # keep out of web root
  'feed_file' => 'atom.xml',
  'num_posts_feed' => 25,
  'num_posts_page' => 100,
  'page_title' => 'mmb url share',
  'root_url' => 'http://matthewm.boedicker.org/urlshare/',
}

cgi = CGI.new

db = SQLite3::Database.new('murlsh.db')
db.results_as_hash = true

cookies = []
status = 'OK'
result = []

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
      db.type_translation = true
      db.translator.add_translator('timestamp') do |t, v|
        Time.parse(v + ' gmt')
      end
      require 'titler'
      db.execute(
        "INSERT INTO url (time, url, email, name, title) VALUES (DATETIME('NOW'), ?, ?, ?, ?)",
        cgi['url'], user[:email], user[:name], Titler::get_title(cgi['url']))
      result = db.execute('SELECT * FROM url ORDER BY id DESC LIMIT ?',
        config['num_posts_feed'])

      open(config['feed_file'], 'w') do |f|
        f.flock File::LOCK_EX

        xm = Builder::XmlMarkup.new(:target => f)
        xm.instruct! :xml

        xm.feed(:xmlns => 'http://www.w3.org/2005/Atom') {
          xm.id(config['root_url'])
          xm.link(:href => "#{config['root_url']}#{config['feed_file']}",
            :rel => 'self')
          xm.title(config['page_title'])
          xm.updated(result.collect { |u| u['time'] }.max.xmlschema)
          uri_parsed = URI.parse(config['root_url'])
          host, domain = uri_parsed.host.match(
            /^(.*?)\.?([^.]+\.[^.]+)$/).captures
          result.each do |u|
            xm.entry {
              xm.author { xm.name(u['name']) }
              xm.title(u['title'])
              xm.id("tag:#{domain},#{u['time'].strftime('%Y-%m-%d')}:#{host}#{uri_parsed.path}#{u['id']}")
              xm.summary(u['title'])
              xm.updated(u['time'].xmlschema)
              xm.link(:href => u['url'])
            }
          end
        }

        f.flock File::LOCK_UN
      end

      result = result[0,1]

      result.collect! { |i| i.each_key { |k| i[k] = i[k].to_s.to_xs  }  }

      cookies.push(CGI::Cookie::new(
        'expires' => Time.mktime(2015, 6, 22),
        'name' => 'auth',
        'path' => '/',
        'value' => cgi['auth']))
    else
      status = 'FORBIDDEN'
    end
  else
    status = 'SERVER_ERROR'
  end

  cgi.out('cookie' => cookies, 'status' => status,
    'type' => 'application/json') {
    JSON.generate(result)
  }
else
  cgi.out('status' => 'MOVED', 'Location' => config['root_url']) { '' }
end

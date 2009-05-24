#!/usr/bin/ruby
require 'murlsh'

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
      db = SQLite3::Database.new('murlsh.db')
      db.results_as_hash = true
      db.type_translation = true
      db.translator.add_translator('timestamp') do |t, v|
        Time.parse(v + ' gmt')
      end
      require 'titler'
      db.execute(
        "INSERT INTO url (time, url, email, name, title) VALUES (DATETIME('NOW'), ?, ?, ?, ?)",
        cgi['url'], user[:email], user[:name], Titler::get_title(cgi['url']))
      result = db.execute('SELECT * FROM url ORDER BY id DESC LIMIT ?',
        config['num_posts_feed']).collect { |u| Murlsh::Url.new(u) }

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

      result = result[0,1]

      body = JSON.generate(result)
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

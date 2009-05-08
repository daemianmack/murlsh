#!/usr/bin/ruby
require 'titler'

require 'cgi'
require 'digest/md5'
require 'json'
require 'uri'

require 'rubygems'
require 'builder'
require 'sqlite3'

def email_md5(s)
  s.index('@', 1).nil? ? ((s.size == 32) ? s : '') : Digest::MD5.hexdigest(s)
end

config = {
  'feed_file' => 'atom.xml',
  'num_posts_feed' => 25,
  'num_posts_page' => 100,
  'page_title' => 'mmb url share',
  'root_url ' => 'http://matthewm.boedicker.org/urlshare/',
}

cgi = CGI.new

db = SQLite3::Database.new('murlsh.db')
db.results_as_hash = true

if cgi.request_method  == 'POST'
  unless cgi['url'].empty?
    db.type_translation = true
    db.translator.add_translator('timestamp') { |t, v| Time.parse(v + ' gmt') }
    db.execute(
      "INSERT INTO url (time, url, email, name, title) VALUES (DATETIME('NOW'), ?, ?, ?, ?)",
        cgi['url'], email_md5(cgi['email']), cgi['name'],
        Titler::get_title(cgi['url']))
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
        path = uri_parsed.path
        result.each do |u|
          xm.entry {
            xm.author { xm.name(u['name']) }
            xm.title(u['title'])
            xm.id("tag:#{domain},#{u['time'].strftime('%Y-%m-%d')}:#{host}#{path}#{u['id']}")
            xm.summary(u['title'])
            xm.updated(u['time'].xmlschema)
            xm.link(:href => u['url'])
          }
        end
      }

      f.flock File::LOCK_UN
    end

    result = result[0,1]
  else
    result = {}
  end
else
  result = db.execute('SELECT * FROM url ORDER BY id DESC LIMIT ?',
    cgi['n'].empty? ? config['num_posts_page'] : cgi['n'].to_i)
end

result.collect! { |i| i.each_key { |k| i[k] = i[k].to_s.to_xs  }  }

def bake_cookies(hash)
  hash.each do |k,v|
    yield CGI::Cookie::new(
      'expires' => Time.mktime(2015, 6, 22),
      'name' => k,
      'path' => '/',
      'value' => v) unless v.empty?
  end
end

cookies = []
bake_cookies('name' => cgi['name'], 'email' => cgi['email']) do |c|
  cookies.push(c)
end

cgi.out('cookie' => cookies, 'type' => 'application/json') {
  JSON.generate(result)
}

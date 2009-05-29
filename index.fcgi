#!/usr/bin/ruby
$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'murlsh'

require 'rubygems'
require 'builder'
require 'sqlite3'

require 'cgi'
require 'fcgi'
require 'yaml'

config = YAML.load_file('config.yaml')

db = SQLite3::Database.new(config['db_file'])
db.results_as_hash = true
db.create_function('MATCH', 2) do |func,search_in,search_for|
  func.result = search_in.to_s.match(/#{search_for}/i) ? 1 : nil
end

FCGI.each do |req|
  qs = Murlsh.parse_query(req.env['QUERY_STRING'])

  content_type = Murlsh.xhtml_content_type(req.env['HTTP_ACCEPT'],
    req.env['HTTP_USER_AGENT'])
  req.out.print("Content-Type: #{content_type}\n\n")

  xm = Builder::XmlMarkup.new(:indent => 2, :target => req.out)
  xm.instruct! :xml
  xm.declare! :DOCTYPE, :html, :PUBLIC, '-//W3C//DTD XHTML 1.1//EN',
    'http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd'

  xm.html(:xmlns => 'http://www.w3.org/1999/xhtml',
    :'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
    :'xsi:schemaLocation' => 'http://www.w3.org/MarkUp/SCHEMA/xhtml11.xsd',
    :'xml:lang' => 'en') {
    xm.head {
      xm.title(config['page_title'] + (qs['q'] ? " /#{qs['q']}" : ''))
      xm.link(:rel => 'stylesheet', :type => 'text/css', :href => 'screen.css')
      xm.link(:rel => 'alternate', :type => 'application/atom+xml',
        :href => config['feed_file'])
    }
    xm.body {
      xm.div(:id => 'header') {
        Murlsh::Referrer.new(req.env['HTTP_REFERER']).search_query do |refq|
          xm.p {
            xm << 'search this site for '
            re_parts = refq.split.collect { |x| Regexp.escape(x) }
            re = "\\b(#{re_parts.join('|')})\\b"
            xm.a(refq, :href => '?q=' + CGI::escape(re))
          }
        end
        xm.p {
          xm.form(:action => '', :method => 'get') {
            xm.a(:href => config['feed_file']) {
              xm.img(:src => 'feed-icon-14x14.png', :width => 14, :height => 14,
                :alt => 'Atom feed', :title => 'Atom feed')
            }
            xm.input(:type => 'text', :id => 'q', :name => 'q', :size => 16,
              :value => qs['q'])
            xm.input(:type => 'submit', :value=> 'Regex Search')
          }
        }
      }
      xm.ul(:id => 'urls') {
        params = {
          'limit' => qs['n'] ? qs['n'].to_i : config['num_posts_page']
          }
        if qs['q']
          where = ' WHERE ' +
            ['name', 'title', 'url'].collect { |x| "MATCH(#{x}, :q)" }.join(
              ' OR ')
          params['q'] = qs['q']
        else
          where = ''
        end

        last = nil
        db.execute("SELECT * FROM url#{where} ORDER BY id DESC LIMIT :limit",
          params).collect { |u| Murlsh::Url.new(u) }.each do |mu|
          xm.li {
            unless mu.same_author?(last)
              xm.div(:class => 'icon') {
                xm.img(
                  :alt => mu.name,
                  :height => config['gravatar_size'],
                  :src => "http://www.gravatar.com/avatar/#{mu.email}?s=#{config['gravatar_size']}",
                  :title => mu.name,
                  :width => config['gravatar_size']) if mu.email
              }
              xm.div(mu.name, :class => 'name') if mu.name
            end

            xm.a(mu.title.strip.gsub(/\s+/, ' '), :href => mu.url)

            mu.hostrec { |hostrec| xm.span(hostrec, :class => 'host') }
            last = mu
          }
        end
      }
      xm.div(:style => 'clear : both')

      xm.p {
        xm.form(:action => 'ajax.cgi', :method => 'post') {
          xm.label('Add URL:', :for => 'url')
          xm.input(:type => 'text', :id => 'url', :name => 'url', :size => 32)
          xm.label('Auth:', :for => 'auth')
          xm.input(:type => 'password', :id => 'auth', :name => 'auth',
            :size => 16)
          xm.input(:type => 'button', :id => 'submit', :value => 'Add')
        }
      }

      xm.p {
        xm << 'built with '
        xm.a('murlsh', :href => 'http://github.com/mmb/murlsh/')
      }
      ['jquery-1.3.2.min.js', 'jquery.cookie.js', 'js.js'].each do |x|
        xm.script('', :type => 'text/javascript', :src => x)
      end
    }
  }

  req.finish
end

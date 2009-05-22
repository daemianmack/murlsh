#!/usr/bin/ruby

require 'hostrec'

require 'cgi'
require 'fcgi'

require 'rubygems'
require 'builder'
require 'sqlite3'

config = {
  'feed_file' => 'atom.xml',
  'gravatar_size' => 32,
  'num_posts_page' => 100,
  'page_title' => 'mmb url share'
}

db = SQLite3::Database.new('murlsh.db')
db.results_as_hash = true

FCGI.each do |req|
  qs = CGI::parse(req.env['QUERY_STRING'])
  if req.env['HTTP_USER_AGENT'].downcase.index('msie')
    content_type = 'text/html'
  else
    content_type = 'application/xhtml+xml'
  end
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
      xm.title(config['page_title'] +
        (qs['q'].empty? ? '' : ' | grep ' + qs['q'].first))
      xm.link(:rel => 'stylesheet', :type => 'text/css', :href => 'screen.css')
      xm.link(:rel => 'alternate', :type => 'application/atom+xml',
        :href => config['feed_file'])
    }
    xm.body {
      xm.div(:id => 'header') {
        xm.p {
          xm.form(:action => '', :method => 'get') {
            xm.a(:href => config['feed_file']) {
              xm.img(:src => 'feed-icon-14x14.png', :width => 14, :height => 14,
                :alt => 'Atom feed', :title => 'Atom feed')
            }
            xm.label('Search:', :for => 'q')
            xm.input(:type => 'text', :id => 'q', :name => 'q', :size => 16,
            :value => qs['q'].empty? ? '' : qs['q'].first)
          }
        }
      }
      xm.ul(:id => 'urls') {
        last = nil
        params = {}
        if qs['n'].empty?
          params['limit'] = config['num_posts_page']
        else
          params['limit'] = qs['n'].first.to_i
        end
        if qs['q'].empty?
          where = ''
        else
          where = ' WHERE ' +
            ['name', 'title', 'url'].collect { |x| "#{x} LIKE :q" }.join(' OR ')
          params['q'] = "%#{qs['q'].first}%"
        end

        db.execute("SELECT * FROM url#{where} ORDER BY id DESC LIMIT :limit",
          params).each do |u|
          xm.li {
            same_as_last = last and last['email'] and last['name'] and
              u['email'] and u['name'] and
              u['email'] == last['email'] and u['name'] == last['name']

            unless same_as_last
              xm.div(:class => 'icon') {
                xm.img(
                  :alt => u['name'],
                  :height => config['gravatar_size'],
                  :src => "http://www.gravatar.com/avatar/#{u['email']}?s=#{config['gravatar_size']}",
                  :title => u['name'],
                  :width => config['gravatar_size']) if u['email']
              }
              xm.div(u['name'], :class => 'name') if u['name']
            end

            xm.a(u['title'].strip.gsub(/\s+/, ' '), :href => u['url'])
            HostRec::hostrec(u['url'], u['title']) do |hostrec|
              xm.span(hostrec, :class => 'host')
            end
            last = u
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
      xm.script('', :type => 'text/javascript', :src => 'jquery-1.3.2.min.js')
      xm.script('', :type => 'text/javascript', :src => 'jquery.cookie.js')
      xm.script('', :type => 'text/javascript', :src => 'js.js')
    }
  }

  req.finish
end

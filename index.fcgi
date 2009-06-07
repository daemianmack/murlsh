#!/usr/bin/ruby
$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'murlsh'

require 'rubygems'
require 'active_record'
require 'sqlite3'

require 'cgi'
require 'fcgi'
require 'yaml'

config = YAML.load_file('config.yaml')

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3', :database => config['db_file'])

db = ActiveRecord::Base.connection.instance_variable_get(:@connection)
db.create_function('MATCH', 2) do |func,search_in,search_for|
  func.result = search_in.to_s.match(/#{search_for}/i) ? 1 : nil
end

FCGI.each do |req|
  qs = Murlsh.parse_query(req.env['QUERY_STRING'])

  content_type = Murlsh.xhtml_content_type(req.env['HTTP_ACCEPT'],
    req.env['HTTP_USER_AGENT'])
  req.out.print("Content-Type: #{content_type}\n\n")

  xm = Murlsh::Markup.new(:indent => 2, :target => req.out)
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
      xm.ul(:id => 'urls') {

        xm.li {
          xm.div(:class => 'icon') {
            xm.a(:href => config['feed_file']) {
              xm.img(
                :alt => 'Atom feed',
                :height => 28,
                :src => 'feed-icon-28x28.png',
                :title => 'Atom feed',
                :width => 28)
            }
          }
          xm.form(:action => '', :method => 'get') {
            value = qs['q']
            Murlsh::Referrer.new(req.env['HTTP_REFERER']).search_query do |refq|
              re_parts = refq.split.collect { |x| Regexp.escape(x) }
              value = "\\b(#{re_parts.join('|')})\\b"
            end
            xm.input(:type => 'text', :id => 'q', :name => 'q', :size => 32,
              :value => value)
            xm.input(:type => 'submit', :value=> 'Regex Search')
          }
        }

        conditions = []
        if qs['q']
          search_cols = %w{name title url}
          conditions = [search_cols.collect { |x| "MATCH(#{x}, ?)" }.join(' OR ')].push(
            *[qs['q']] * search_cols.size)
        end

        last = nil
        author_group = 1

        Murlsh::Url.all(:conditions => conditions,
          :order => 'id DESC',
          :limit =>  qs['n'] ? qs['n'].to_i : config['num_posts_page']
          ).each do |mu|
          first_class = ''
          unless mu.same_author?(last)
            author_group = (author_group + 1) % 2
            first_class = ' author_first' 
          end

          xm.li(:class => "author_group_#{author_group}#{first_class}") {
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
          xm.label('Password:', :for => 'auth')
          xm.input(:type => 'password', :id => 'auth', :name => 'auth',
            :size => 16)
          xm.input(:type => 'button', :id => 'submit', :value => 'Add')
        }
      }

      xm.p {
        xm << 'built with '
        xm.a('murlsh', :href => 'http://github.com/mmb/murlsh/')
      }
      xm.javascript(%w{jquery-1.3.2.min.js jquery.cookie.js js.js},
        :prefix => 'js/')
    }
  }

  req.finish
end

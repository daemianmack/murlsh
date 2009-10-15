module Murlsh

  class UrlBody < Builder::XmlMarkup
    include Murlsh::Markup

    def initialize(config, db, req, urls)
      @config, @db, @req, @urls = config, db, req, urls
      super(:indent => 2)
    end

    def each
      q = @req.params['q']

      instruct! :xml
      declare! :DOCTYPE, :html, :PUBLIC, '-//W3C//DTD XHTML 1.1//EN',
        'http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd'

      yield html(:xmlns => 'http://www.w3.org/1999/xhtml',
        :'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
        :'xsi:schemaLocation' => 'http://www.w3.org/MarkUp/SCHEMA/xhtml11.xsd',
        :'xml:lang' => 'en') {
        head {
          title(@config.fetch('page_title', '') + (q ? " /#{q}" : ''))
          metas(
            :description => @config.fetch('description', ''),
            :viewport =>
              'width=device-width,minimum-scale=1.0,maximum-scale=1.0')
          (gv = @config.fetch('google_verify')) and metas('verify-v1' => gv)
          css(@config.fetch('css_files', []),
            :prefix => @config.fetch('css_prefix', ''))
          css('phone.css',
            :media => 'only screen and (max-device-width: 480px)',
            :prefix => @config.fetch('css_prefix', ''))
          atom(@config.fetch('feed_file'))
        }
        body {
          ul(:id => 'urls') {
            li {
              div(:class => 'icon') {
                a('feed', :href => @config.fetch('feed_file'),
                  :class => 'feed')
              }
              form(:action => '', :method => 'get') {
                value = q
                Murlsh::Referrer.new(@req.referrer).search_query do |refq|
                  re_parts = refq.split.collect { |x| Regexp.escape(x) }
                  value = "\\b(#{re_parts.join('|')})\\b"
                end
                fieldset {
                  input(:type => 'text', :id => 'q', :name => 'q', :size => 32,
                    :value => value)
                  input(:type => 'submit', :value=> 'Regex Search')
                }
              }
            }

            last = nil

            @urls.each do |mu|
              li {
                unless mu.same_author?(last)
                  gravatar_size = @config.fetch('gravatar_size', 0)
                  div(:class => 'icon') {
                    gravatar(mu.email, 's' => gravatar_size, :text => mu.name)
                  } if mu.email and gravatar_size > 0
                  div(mu.name, :class => 'name') if mu.name
                end

                a(mu.title.strip.gsub(/\s+/, ' '), :href => mu.url)

                mu.hostrec { |hostrec| span(hostrec, :class => 'host') }
                span(", #{mu.time.fuzzy}", :class => 'date') if
                  @config.fetch('show_dates', true)
                last = mu
              }
            end

            li {
              form(:action => '', :method => 'post') {
                fieldset(:id => 'add') {
                  self.p {
                    label('Add URL:', :for => 'url')
                    input(:type => 'text', :id => 'url', :name => 'url',
                      :size => 32)
                  }
                  self.p {
                    label('Password:', :for => 'auth')
                    input(:type => 'password', :id => 'auth', :name => 'auth',
                      :size => 16)
                    input(:type => 'button', :id => 'submit', :value => 'Add')
                  }
                }
              }
            }
          }

          div(:style => 'clear : both')

          self.p {
            text! 'powered by '
            a('murlsh', :href => 'http://github.com/mmb/murlsh/')
          }
          javascript(%w{
            jquery-1.3.2.min.js
            jquery.cookie.js
            jquery.jgrowl_compressed.js
            js.js
            }, :prefix => @config.fetch('js_prefix', ''))
        }
      }
    end

  end

end

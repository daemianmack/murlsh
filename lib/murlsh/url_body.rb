module Murlsh

  # Url list page builder.
  class UrlBody < Builder::XmlMarkup
    include Murlsh::Markup

    def initialize(config, db, req)
      @config, @db, @req, @q = config, db, req, req.params['q']
      super(:indent => 2)
    end

    # Fetch urls base on query string parameters.
    def urls
      Murlsh::Url.all(:conditions => search_conditions, :order => 'id DESC',
        :limit =>  @req.params['n'] ? @req.params['n'].to_i :
          @config.fetch('num_posts_page', 100))
    end

    # Search conditions builder for ActiveRecord conditions.
    def search_conditions
      if @q
        search_cols = %w{name title url}
        [search_cols.collect { |x| "MATCH(#{x}, ?)" }.join(' OR ')].push(
          *[@q] * search_cols.size)
      else
        []
      end
    end

    # Url list page body builder.
    def each
      instruct! :xml
      declare! :DOCTYPE, :html, :PUBLIC, '-//W3C//DTD XHTML 1.1//EN',
        'http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd'

      yield html(:xmlns => 'http://www.w3.org/1999/xhtml',
        :'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
        :'xsi:schemaLocation' => 'http://www.w3.org/MarkUp/SCHEMA/xhtml11.xsd',
        :'xml:lang' => 'en') {
        headd
        body {
          in_page_a('top')
          ul(:id => 'urls') {
            li { feed_icon ; search_form }

            gravatar_size = @config.fetch('gravatar_size', 0)

            last = nil
            urls.each do |mu|
              li {
                unless mu.same_author?(last)
                  div(:class => 'icon') {
                    gravatar(mu.email, 's' => gravatar_size, :text => mu.name)
                  } if mu.email and gravatar_size > 0
                  div(mu.name, :class => 'name') if mu.name
                end

                a(mu.title.strip.gsub(/\s+/, ' '), :href => mu.url)

                mu.hostrec { |hostrec| span(hostrec, :class => 'host') }
                span(", #{mu.time.fuzzy}", :class => 'date') if
                  @config.fetch('show_dates', true) and mu.time
                last = mu
              }
            end

            li { add_form }
          }

          clear
          powered_by
          js
          in_page_a('bottom')
        }
      }
    end

    # Head builder.
    def headd
      head {
        titlee
        metas(:description => @config.fetch('description', ''),
          :viewport =>
            'width=device-width,minimum-scale=1.0,maximum-scale=1.0')
        google_verify
        css(@config.fetch('css_files', []),
          :prefix => @config.fetch('css_prefix', ''))
        css('phone.css', :media => 'only screen and (max-device-width: 480px)',
          :prefix => @config.fetch('css_prefix', ''))
        atom(@config.fetch('feed_file'))
      }
    end

    # Title builder.
    def titlee
      title(@config.fetch('page_title', '') + (@q ? " /#{@q}" : ''))
    end

    # Google verification link builder.
    def google_verify
      (gv = @config.fetch('google_verify')) and metas('verify-v1' => gv)
    end

    # Feed icon builder.
    def feed_icon
      div(:class => 'icon') {
        a('feed', :href => @config.fetch('feed_file'), :class => 'feed')
      }
    end

    # Search form builder.
    def search_form
      form(:action => '', :method => 'get') {
        value = @q
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
    end

    # Url add form builder.
    def add_form
      form(:action => '', :method => 'post') {
        fieldset(:id => 'add') {
          self.p { add_form_input('Add URL:', 'url', 32) }
          self.p {
            add_form_input('Password:', 'auth', 16, 'password')
            input(:type => 'button', :id => 'submit', :value => 'Add')
          }
        }
      }
    end

    # Url add form input builder.
    def add_form_input(label, id, size, tipe='text')
      label(label, :for => id)
      input(:type => tipe, :id => id, :name => id, :size => size)
    end

    # Clear div builder.
    def clear
      div(:style => 'clear : both')
    end

    # Powered by builder.
    def powered_by
      self.p {
        text! 'powered by '
        a('murlsh', :href => 'http://github.com/mmb/murlsh/')
      }
    end

    # Required javascript builder.
    def js
      javascript(%w{
        jquery-1.3.2.min.js
        jquery.cookie.js
        jquery.jgrowl_compressed.js
        js.js
        }, :prefix => @config.fetch('js_prefix', ''))
    end

  end

end

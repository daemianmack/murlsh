module Murlsh

  # Url list page builder.
  class UrlBody < Builder::XmlMarkup
    include Murlsh::Markup

    def initialize(config, db, req)
      @config, @db, @req, @q = config, db, req, req.params['q']
      super(:indent => @config['xhtml_indent'] || 0)
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
        [search_cols.map { |x| "MATCH(#{x}, ?)" }.join(' OR ')].push(
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
                  div(mu.name, :class => 'name') if
                    @config.fetch('show_names', false) and mu.name
                end

                a(mu.title_stripped, :href => mu.url, :class => 'm')

                mu.hostrec do |hostrec|
                  self.span(" [#{hostrec}]", :class => 'host')
                end
                mu.viarec do |via|
                  display_via = Murlsh::Plugin.hooks('via').inject(
                    via) { |result,plugin| plugin.run(result) }
                  span(:class => 'via') {
                    text!(' via '); a(display_via, :href => via)
                  }
                end

                display_time = Murlsh::Plugin.hooks('time').inject(
                  mu.time) { |result,plugin| plugin.run(result) }
                span(", #{display_time}", :class => 'date') if display_time
                last = mu
              }
            end

            li { add_form }
          }

          clear
          powered_by
          js
          div('', :id => 'bottom')
        }
      }
    end

    # Head builder.
    def headd
      head {
        titlee
        metas(@config.select { |k,v| k =~ /^meta_tag_/ and v }.
          map { |k,v| [k.sub('meta_tag_', ''), v] })
        css(@config['css_compressed'] || @config['css_files'])
        atom(@config.fetch('feed_file'))
      }
    end

    # Title builder.
    def titlee
      title(@config.fetch('page_title', '') + (@q ? " /#{@q}" : ''))
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
        fieldset {
          form_input(:id => 'q', :size => 32, :value => @q)
          form_input(:type => 'submit', :value => 'Regex Search')
        }
      }
    end

    # Url add form builder.
    def add_form
      form(:action => '', :method => 'post') {
        fieldset(:id => 'add') {
          self.p { form_input(:id => 'url', :label => 'Add URL', :size => 32) }
          self.p { form_input(:id => 'via', :label => 'Via', :size => 32) }
          self.p {
            form_input(:id => 'auth', :label => 'Password', :size => 16,
              :type => 'password')
            form_input(:id => 'submit', :type => 'button', :value => 'Add')
          }
        }
      }
    end

    # Clear div builder.
    def clear; div(:style => 'clear : both') { }; end

    # Powered by builder.
    def powered_by
      self.p {
        text! 'powered by '
        a('murlsh', :href => 'http://github.com/mmb/murlsh/')
      }
    end

    # Required javascript builder.
    def js; javascript(@config['js_compressed'] || @config['js_files']); end

  end

end

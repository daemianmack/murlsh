module Murlsh

  module Markup

    def javascript(sources, options={})
      sources.to_a.each do |src|
        script('', :type => 'text/javascript',
          :src => "#{options[:prefix]}#{src}")
      end
    end

    def murlsh_img(options={})
      img_convert_prefix(options)
      img_convert_size(options)
      img_convert_text(options)

      if options[:href]
        a(:href => options[:href]) {
          options.delete(:href)
          img(options)
        }
      else
        img(options)
      end
    end

    def atom(href)
      link(:rel => 'alternate', :type => 'application/atom+xml', :href => href)
    end

    def css(hrefs, options={})
      hrefs.to_a.each do |href|
        attrs = {
          :href => "#{options[:prefix]}#{href}",
          :rel => 'stylesheet',
          :type => 'text/css',
        }
        attrs[:media] = options[:media] if options[:media]
        link(attrs)
      end
    end

    def metas(tags)
      tags.each { |k,v| meta(:name => k, :content => v) }
    end

    def gravatar(email_hash, options={})
      query = options.reject do |k,v|
        not ((k == 'd' and %w{identicon monsterid wavatar}.include?(v)) or
        (k =='s' and (0..512).include?(v)) or
        (k == 'r' and %w{g pg r x}.include?(v)))
      end

      return if query['s'] and query['s'] < 1

      options.reject! { |k,v| %w{d s r}.include?(k) }
      options[:src] = URI.join('http://www.gravatar.com/avatar/',
        email_hash + build_query(query))

      murlsh_img(options)
    end

    def build_query(h)
      h.empty? ? '' :
        '?' + h.collect { |k,v| URI.escape("#{k}=#{v}") }.join('&')
    end

    private

    def img_convert_prefix(options)
      if options.has_key?(:prefix) and options.has_key?(:src)
        options[:src] = options[:prefix] + options[:src]
        options.delete(:prefix)
      end
    end

    def img_convert_size(options)
      if options.has_key?(:size)
        if options[:size].kind_of?(Array) and options[:size].size == 2
          options[:width], options[:height] = options[:size]
        else
          options[:width] = options[:height] = options[:size]
        end
        options.delete(:size)
      end
    end

    def img_convert_text(options)
      if options.has_key?(:text)
        options[:alt] = options[:title] = options[:text]
        options.delete(:text)
      end
    end

  end

end

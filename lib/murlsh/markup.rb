require 'rubygems'
require 'builder'

module Murlsh

  class Markup < Builder::XmlMarkup

    def javascript(sources, options={})
      (sources.respond_to?(:each) ? sources : [sources]).each do |src|
        script('', :type => 'text/javascript',
          :src => "#{options[:prefix]}#{src}")
      end
    end

    def murlsh_img(options={})
      img_convert_prefix(options)
      img_convert_size(options)
      img_convert_text(options)

      img(options)
    end

    def a_img(options={})
      a(:href => options[:href]) {
        options.delete(:href)
        murlsh_img(options)
      }
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

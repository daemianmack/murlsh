require 'rubygems'
require 'hpricot'
require 'htmlentities'

require 'iconv'
require 'open-uri'
require 'uri'

module Murlsh

  module_function

  def get_title(url, options={})
    options = { :failproof => true }.merge(options)
    result = nil
    begin
      options[:content_type] ||= get_content_type(url, options)
      if might_have_title(options[:content_type])
        f = open(url, 'User-Agent' =>
          'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.4) Gecko/20030624')

        doc = Hpricot(f)

        result = HTMLEntities.new.decode(Iconv.conv('utf-8',
          get_charset(doc) || f.charset, find_title(doc)))
      end
    rescue Exception => e
       raise unless options[:failproof]
    end
    result || url
  end

  def might_have_title(content_type)
    content_type[/^text\/html/]
  end

  # Find the title in an Hpricot document.
  def find_title(doc)
    %w{//html/head/title //head/title //html/title //title}.each do |xpath|
      return (doc/xpath).first.inner_html unless (doc/xpath).first.nil?
    end
  end

  # Get the character set of an Hpricot document.
  def get_charset(doc)
    %w{content-type Content-Type}.each do |ct|
      content_type = doc.at("meta[@http-equiv='#{ct}']")
      unless content_type.nil?
        content = content_type['content']
        unless content.nil?
          charset = content[/charset=([\w_.:-]+)/, 1]
          return charset if charset
        end
      end
    end
    nil
  end

end

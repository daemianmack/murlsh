require 'rubygems'
require 'hpricot'
require 'htmlentities'

require 'iconv'
require 'open-uri'
require 'uri'

module Murlsh

  module_function

  # Try to get the title of a url. Options:
  # :failproof - if true hide all exceptions and return empty string on failure
  # :headers - hash of headers to send in request
  def get_title(url, options={})
    options[:headers] = default_headers(url).merge(
      options.fetch(:headers, {}))

    options = {
      :failproof => true,
      }.merge(options)

    result = nil
    begin
      options[:content_type] ||= get_content_type(url, options)
      if might_have_title(options[:content_type])
        f = open(url, options[:headers])

        doc = Hpricot(f)

        result = HTMLEntities.new.decode(Iconv.conv('utf-8',
          get_charset(doc) || f.charset, find_title(doc)))
      end
    rescue Exception => e
       raise unless options[:failproof]
    end
    (result and !result.empty?) ? result : url
  end

  # Return true if the content type is likely to have a title that can be
  # parsed.
  def might_have_title(content_type)
    content_type[/^text\/html/]
  end

  # Find the title in an Hpricot document.
  def find_title(doc)
    %w{//html/head/title //head/title //html/title //title}.each do |xpath|
      return (doc/xpath).first.inner_html unless (doc/xpath).first.nil?
    end
    nil
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

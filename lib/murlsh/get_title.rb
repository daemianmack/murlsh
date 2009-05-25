require 'rubygems'
require 'hpricot'
require 'htmlentities'

require 'iconv'
require 'net/http'
require 'net/https'
require 'open-uri'
require 'uri'

module Murlsh

  def get_title(url)
    result = nil
    begin
      uri_parsed = URI.parse(url)

      net_http = Net::HTTP.new(uri_parsed.host, uri_parsed.port)
      net_http.use_ssl = (uri_parsed.scheme == 'https')

      net_http.start do |http|
        if http.request_head(uri_parsed.path)['content-type'].match(
          /^text\/html/)
          f = open(url, 'User-Agent' =>
            'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.4) Gecko/20030624')

          doc = Hpricot(f)

          test_xpaths = ['//html/head/title', '//head/title', '//html/title',
            '//title']

          test_xpaths.each { |xpath|
            unless (doc/xpath).first.nil?
              charset = f.charset
              ['content-type', 'Content-Type'].each do |ct|
                content_type = doc.at("meta[@http-equiv='#{ct}']")
                unless content_type.nil?
                  content = content_type['content']
                  unless content.nil?
                    match = content.match(/charset=([\w_.:-]+)/)
                    unless match.nil?
                      charset = match[1]
                      break
                    end
                  end
                end
              end

              result = HTMLEntities.new.decode(
                Iconv.conv('utf-8', charset, (doc/xpath).first.inner_html))
              break
            end
          }
        end
      end
    rescue Exception => e
      # puts e.message
    end
    result = url if result.nil? or result.empty?
    result
  end

  module_function :get_title

end

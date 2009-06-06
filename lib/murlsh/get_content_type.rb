require 'net/http'
require 'net/https'
require 'uri'

module Murlsh

  def get_content_type(url, redirects=0)
    unless redirects > 3
      begin
        url = URI.parse(url) unless url.is_a?(URI::HTTP)

        net_http = Net::HTTP.new(url.host, url.port)
        net_http.use_ssl = (url.scheme == 'https')
        # net_http.set_debug_output(STDOUT)

        net_http.start do |http|
          resp = http.request_head(url.path)
          case resp
            when Net::HTTPSuccess then return resp['content-type']
            when Net::HTTPRedirection then
              return get_content_type(resp['location'], redirects + 1)
          end
        end
      rescue Exception => e
        # puts e.message
      end
    end
    ''
  end

  module_function :get_content_type

end

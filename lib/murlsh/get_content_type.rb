require 'net/http'
require 'net/https'
require 'uri'

module Murlsh

  def get_content_type(url)
    begin
      url = URI.parse(url) unless url.is_a?(URI::HTTP)

      net_http = Net::HTTP.new(url.host, url.port)
      net_http.use_ssl = (url.scheme == 'https')

      net_http.start do |http|
        resp = http.request_head(url.path)
        return resp['content-type'] if resp.code == '200'
      end
    rescue Exception => e
      # puts e.message
    end
    ''
  end

  module_function :get_content_type

end

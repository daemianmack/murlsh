require 'net/http'
require 'net/https'
require 'uri'

module Murlsh

  def get_content_type(url)
    begin
      uri_parsed = URI.parse(url)

      net_http = Net::HTTP.new(uri_parsed.host, uri_parsed.port)
      net_http.use_ssl = (uri_parsed.scheme == 'https')

      net_http.start do |http|
        resp = http.request_head(uri_parsed.path)
        return resp['content-type'] if resp.code == '200'
      end
    rescue Exception => e
      # puts e.message
      nil
    end
  end

  module_function :get_content_type

end

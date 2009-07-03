require 'net/http'
require 'net/https'
require 'uri'

module Murlsh

  module_function

  def get_content_type(url, options={})
    options = { :failproof => true, :redirects => 0}.merge(options)
    unless options[:redirects] > 3
      begin
        url = parse_uri(url)

        make_net_http(url, options).start do |http|
          resp = get_resp(http, url)
          case resp
            when Net::HTTPSuccess then return resp['content-type']
            when Net::HTTPRedirection then
            options[:redirects] += 1
            return get_content_type(resp['location'], options)
          end
        end
      rescue Exception => e
        raise unless options[:failproof]
      end
    end
    ''
  end

  # Parse a URI if it's not already parsed.
  def parse_uri(uri)
    uri.is_a?(URI::HTTP) ? uri : URI.parse(uri)
  end

  def make_net_http(url, options={})
    net_http = Net::HTTP.new(url.host, url.port)
    net_http.use_ssl = (url.scheme == 'https')
    net_http.set_debug_output(options[:debug]) if options[:debug]
    net_http
  end

  # Get the response to HTTP HEAD. If HEAD not allowed do GET.
  def get_resp(http, url)
    resp = http.request_head(url.path)
    if Net::HTTPMethodNotAllowed === resp
      http.request_get(url.path)
    else
      resp
    end
  end

end

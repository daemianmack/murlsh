require 'net/http'
require 'net/https'
require 'uri'

class URI::Generic

  def path_query
    path + (query ? "?#{query}" : '')
  end

end

module Murlsh

  module_function

  def get_content_type(url, options={})
    options = {
      :failproof => true,
      :redirects => 0,
      :useragent => 'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.4) Gecko/20030624'
      }.merge(options)
    unless options[:redirects] > 3
      begin
        url = parse_uri(url)

        make_net_http(url, options).start do |http|
          resp = get_resp(http, url, { 'User-Agent' => options[:useragent] })
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
    uri.is_a?(URI::HTTP) ? uri : URI(uri)
  end

  def make_net_http(url, options={})
    net_http = Net::HTTP.new(url.host, url.port)
    net_http.use_ssl = (url.scheme == 'https')
    net_http.set_debug_output(options[:debug]) if options[:debug]
    net_http
  end

  # Get the response to HTTP HEAD. If HEAD not allowed do GET.
  def get_resp(http, url, headers={})
    resp = http.request_head(url.path_query, headers)
    if Net::HTTPMethodNotAllowed === resp
      http.request_get(url.path_query, headers)
    else
      resp
    end
  end

end

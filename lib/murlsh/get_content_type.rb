require 'net/http'
require 'net/https'
require 'uri'

class URI::Generic

  # Return the path and query string.
  def path_query
    path + (query ? "?#{query}" : '')
  end

end

module Murlsh

  module_function

  # Try to get the content type of a url.
  # Options:
  # * :failproof - if true hide all exceptions and return empty string on failure
  # * :headers - hash of headers to send in request
  def get_content_type(url, options={})
    options[:headers] = default_headers(url).merge(
      options.fetch(:headers, {}))

    options = {
      :failproof => true,
      :redirects => 0,
      }.merge(options)

    unless options[:redirects] > 3
      begin
        url = parse_uri(url)

        make_net_http(url, options).start do |http|
          resp = get_resp(http, url, options[:headers])
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

  # Create a Net::HTTP to a host and port.
  # Options:
  # * :debug - stream to write debug output to
  def make_net_http(url, options={})
    net_http = Net::HTTP.new(url.host, url.port)
    net_http.use_ssl = (url.scheme == 'https')
    net_http.set_debug_output(options[:debug]) if options[:debug]
    net_http
  end

  # Get the response to HTTP HEAD. If HEAD returns anything other than success
  # try GET.
  def get_resp(http, url, headers={})
    resp = http.request_head(url.path_query, headers) === Net::HTTPSuccess ?
      resp : http.request_get(url.path_query, headers)
  end

  # Get default headers sent with the request. Can be based on url.
  def default_headers(url)
    result = {
      'User-Agent' =>
        'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.4) Gecko/20030624',
    }
    begin
      parsed_url = parse_uri(url)
      if (parsed_url.host || '')[/^www\.nytimes\.com/]
        result['Referer'] = 'http://news.google.com/'
      end
    rescue URI::InvalidURIError => e
    end

    result
  end

end

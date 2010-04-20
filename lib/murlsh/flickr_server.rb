%w{
digest/sha1
open-uri

json
rack
}.each { |m| require m }

module Murlsh

  # Proxy for Flickr rest API to support conditional get and caching.
  #
  # Passes along query string with api key added, returns result from Flickr
  # with cache-control, etag and last-modified headers set.
  class FlickrServer

    def initialize(config); @config = config; end

    # Proxy a request to the Flickr API.
    def get(req)
      resp = Rack::Response.new

      if @config['flickr_api_key']
        params = req.params.merge('api_key' => @config['flickr_api_key'])

        q = params.map { |k,v| "#{URI.encode(k)}=#{URI.encode(v)}" }.join('&')

        json_wrapped = open("http://api.flickr.com/services/rest/?#{q}") do |f|
          f.read
        end

        json = /.+?\((.+)\)/.match(json_wrapped)[1]

        json_parsed = JSON.parse(json)

        resp['Cache-Control'] = 'public, max-age=86400'
        resp['Content-Type'] = 'application/json'
        resp['ETag'] = "\"#{Digest::SHA1.hexdigest(json_wrapped)}\""
        resp['Last-Modified'] = Time.at(
          json_parsed['photo']['dates']['lastupdate'].to_i).httpdate

        resp.body = json_wrapped

        resp
      else
        Rack::Response.new('flickr_api_key not set in config.yaml', 500,
          { 'Content-Type' => 'text/plain' })
      end

    end

  end

end

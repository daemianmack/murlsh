%w{
open-uri

active_record
json
rack
}.each { |m| require m }

module Murlsh

  # Proxy for Flickr rest API flickr.photos.getinfo call to support conditional
  # get.
  #
  # Passes along query string with api key added, returns result from Flickr
  # with content type set to application/json and last modified header set.
  class FlickrServer

    def initialize(config); @config = config; end

    # Proxy a flickr.photos.getinfo request to the Flickr rest API.
    def get(req)
      resp = Rack::Response.new

      if @config['flickr_api_key']
        params = req.params.merge('api_key' => @config['flickr_api_key'])

        q = params.map { |k,v| "#{URI.encode(k)}=#{URI.encode(v)}" }.join('&')

        json_wrapped = open("http://api.flickr.com/services/rest/?#{q}") do |f|
          # for some reason Firefox will not cache if it's text/plain, which is
          # what Flickr returns
          resp['Content-Type'] = 'application/json'
          f.read
        end

        json = /.+?\((.+)\)/.match(json_wrapped)[1]

        json_parsed = JSON.parse(json)

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

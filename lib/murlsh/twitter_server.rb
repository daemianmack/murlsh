%w{
digest/sha1
open-uri

json
rack
}.each { |m| require m }

module Murlsh

  # Proxy for Twitter rest API to support conditional get and caching.
  #
  # Passes along path and query string, returns result from Twitter with
  # cache-control, etag and last-modified headers set.
  class TwitterServer

    # Proxy a request to the Twitter API.
    def get(req)
      resp = Rack::Response.new

      twitter_url = URI.join('http://api.twitter.com',
        req.fullpath[/twitter\/(.+)/, 1])

      json_wrapped = open(twitter_url) do |f|
        resp['Content-Type'] = f.content_type
        f.read
      end

      json = /.+?\((.+)\)/.match(json_wrapped)[1]

      json_parsed = JSON.parse(json)

      resp['Cache-Control'] = 'max-age=86400'
      resp['ETag'] = "\"#{Digest::SHA1.hexdigest(json_wrapped)}\""
      resp['Last-Modified'] = Time.parse(json_parsed['created_at']).httpdate

      resp.body = json_wrapped

      resp
    end

  end

end

%w{
digest/sha1
open-uri

rack

murlsh
}.each { |m| require m }

module Murlsh

  # Proxy for Twitter rest API to support conditional get and caching.
  #
  # Passes along path and query string, returns result from Twitter with
  # cache-control, etag and last-modified headers set.
  class TwitterServer

    include HeadFromGet

    # Proxy a request to the Twitter API.
    def get(req)
      resp = Rack::Response.new

      twitter_url = URI.join('http://api.twitter.com',
        req.fullpath[/twitter\/(.+)/, 1])

      json_wrapped = open(twitter_url) do |f|
        resp['Content-Type'] = f.content_type
        f.read
      end

      json_parsed = Murlsh::unwrap_jsonp(json_wrapped)

      resp['Cache-Control'] = 'max-age=86400'
      resp['ETag'] = "\"#{Digest::SHA1.hexdigest(json_wrapped)}\""
      resp['Last-Modified'] = Time.parse(json_parsed['created_at']).httpdate

      resp.body = json_wrapped

      resp
    end

  end

end

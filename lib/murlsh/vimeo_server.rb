%w{
digest/sha1
open-uri

rack

murlsh
}.each { |m| require m }

module Murlsh

  # Proxy for Vimeo rest API to support conditional get and caching.
  #
  # Passes along path and query string, returns result from Vimeo with
  # cache-control, etag and last-modified headers set.
  class VimeoServer

    include HeadFromGet

    # Proxy a request to the Vimeo API.
    def get(req)
      resp = Rack::Response.new

      vimeo_url = URI.join('http://vimeo.com', req.fullpath[/vimeo\/(.+)/, 1])

      puts 'contact vimeo'
      json_wrapped = open(vimeo_url) do |f|
        resp['Content-Type'] = f.content_type
        f.read
      end

      json_parsed = Murlsh::unwrap_jsonp(json_wrapped)

      resp['Cache-Control'] = 'max-age=86400'
      resp['ETag'] = "\"#{Digest::SHA1.hexdigest(json_wrapped)}\""
      upload_dates = json_parsed.map do |v|
        # assume gmt because they don't say
        Time.parse("#{v['upload_date']} GMT")
      end
      resp['Last-Modified'] = upload_dates.max.httpdate

      resp.body = json_wrapped

      resp
    end
  end

end

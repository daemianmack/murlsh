module Murlsh

  # m3u builder.
  class M3uBody
    include Murlsh::FeedBody

    # m3u builder.
    def build
      if defined?(@body)
        @body
      else
        result = "# #{feed_url}\r\n\r\n"
        urls.each do |mu|
          result << "#{mu.url}\r\n"
          @updated = @updated ? [@updated, mu.time].max : mu.time
        end

        @body = result
      end
    end

  end

end

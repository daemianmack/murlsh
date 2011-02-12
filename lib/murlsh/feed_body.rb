module Murlsh

  # Feed body mixin.
  module FeedBody

    # Content types to add an enclosure for.
    EnclosureContentTypes = %w{
      application/pdf
      audio/mpeg
      image/gif
      image/jpeg
      image/png
      }

    def initialize(config, req, urls)
      @config, @req, @urls = config, req, urls
      @updated = nil
    end

    # Yield body for Rack.
    def each; yield build; end

    # Build feed title.
    def feed_title
      result = "#{config['page_title']}"
      req['q'] ? "#{result} /#{req['q']}" : result
    end

    attr_reader :config
    attr_reader :req
    attr_reader :urls
    attr_reader :updated
  end

end

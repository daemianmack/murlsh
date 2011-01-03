require 'uri'

module Murlsh

  # Recent urls json response builder.
  class JsonBody

    def initialize(config, req, result_set)
      @config, @req, @result_set = config, req, result_set
    end

    # Recent urls json response builder.
    def each
      urls = @result_set.results.map do |mu|
        h = mu.attributes

        h['title'] = mu.title_stripped

        # add site root url to relative thumbnail urls
        if h['thumbnail_url'] and
          not URI(h['thumbnail_url']).scheme.to_s.downcase[/https?/]
          h['thumbnail_url'] = URI.join(@config['root_url'],
            h['thumbnail_url']).to_s
        end

        h
      end
      yield urls.to_json
    end

  end

end

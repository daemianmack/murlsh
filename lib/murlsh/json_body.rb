require 'uri'

module Murlsh

  # Recent urls json response builder.
  class JsonBody
    include Murlsh::SearchConditions

    def initialize(config, req)
      @config, @req, @q = config, req, req.params['q']
    end

    # Fetch urls based on query string parameters.
    def urls
      Murlsh::Url.all(:conditions => search_conditions, :order => 'time DESC',
        :limit => @config.fetch('num_posts_feed', 25)).map do |mu|
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
    end

    # Recent urls json response builder.
    def each; yield urls.to_json; end

  end

end

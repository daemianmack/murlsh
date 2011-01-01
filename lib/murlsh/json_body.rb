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
        {
          :content_length => mu.content_length,
          :content_type => mu.content_type,
          :email => mu.email,
          :id => mu.id,
          :name => mu.name,
          :thumbnail_url => mu.thumbnail_url,
          :time => mu.time,
          :title => mu.title_stripped,
          :url => mu.url,
          :via => mu.via,
        }
      end
    end

    # Recent urls json response builder.
    def each; yield urls.to_json; end

  end

end

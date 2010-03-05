require 'murlsh'

module Murlsh

  # regenerate atom feed after a new url has been added
  class UpdateFeed < Plugin

    Hook = 'add_post'

    def self.run(config)
      latest = Murlsh::Url.all(:order => 'id DESC',
        :limit => config.fetch('num_posts_feed', 25))

      feed = Murlsh::AtomFeed.new(config.fetch('root_url'),
        :filename => config.fetch('feed_file'),
        :title => config.fetch('page_title', ''),
        :hubs => config.fetch('pubsubhubbub_hubs', []).collect { |x| x['subscribe_url'] } )

      feed.write(latest, config.fetch('feed_file'))
    end

  end

end

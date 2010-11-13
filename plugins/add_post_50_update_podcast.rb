require 'rss/maker'
require 'uri'

require 'murlsh'

module Murlsh

  # Regenerate podcast RSS feed after a new audio/mpeg url has been added.
  class AddPost50UpdatePodcast < Plugin

    @hook = 'add_post'

    def self.run(url, config)
      if url.content_type == 'audio/mpeg'
        output_file = 'podcast.rss'

        feed = RSS::Maker.make('2.0') do |f|
          f.channel.title = f.channel.description = config.fetch(
            'page_title', '')
          f.channel.link = URI.join(config.fetch('root_url'), output_file)
          f.items.do_sort = true
  
          Murlsh::Url.all(:conditions => { :content_type => 'audio/mpeg' },
            :order => 'id DESC',
            :limit => config.fetch('num_posts_feed', 25)).each do |mu|
            i = f.items.new_item
            i.title = mu.title_stripped
            i.link = mu.url
            i.date = mu.time

            i.enclosure.url = mu.url
            i.enclosure.type = mu.content_type
            i.enclosure.length = mu.content_length
          end

        end

        Murlsh::openlock(output_file, 'w') { |f| f.write(feed) }
      end
    end

  end

end

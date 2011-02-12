require 'rss/maker'
require 'uri'

require 'murlsh'

module Murlsh

  # Rss feed builder.
  class RssBody
    include Murlsh::FeedBody

    # Rss feed builder.
    def build
      if defined?(@body)
        @body
      else
        feed = RSS::Maker.make('2.0') do |f|
          f.channel.title = f.channel.description = feed_title
          f.channel.link = URI.join(config.fetch('root_url'), 'rss.rss')
          f.items.do_sort = true

          urls.each do |mu|
            i = f.items.new_item
            i.title = mu.title_stripped
            i.link = mu.url
            i.date = mu.time

            if EnclosureContentTypes.include? mu.content_type
              i.enclosure.url = mu.url
              i.enclosure.type = mu.content_type
              i.enclosure.length = mu.content_length
            end
          end
        end

        @body = feed
      end
    end

  end

end

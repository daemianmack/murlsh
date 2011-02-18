require 'uri'

require 'tinyatom'

require 'murlsh'

module Murlsh

  # Atom feed builder.
  class AtomBody
    include Murlsh::FeedBody

    # Atom feed builder.
    def build
      if defined?(@body)
        @body
      else
        feed = TinyAtom::Feed.new(config.fetch('root_url'), feed_title,
          feed_url, :hubs => config.fetch('pubsubhubbub_hubs', []).
          map { |x| x['subscribe_url'] })

        urls.each do |mu|
          Murlsh::Plugin.hooks('url_display_pre') do |p|
            p.run mu, req, config
          end

          options = {
            :author_name => mu.name,
            :summary => mu.title_stripped
          }

          if EnclosureContentTypes.include?(mu.content_type)
            options.merge!(
              :enclosure_type => mu.content_type,
              :enclosure_href => mu.url,
              :enclosure_title => mu.title
              )
            if mu.content_length
              options.merge! :enclosure_length => mu.content_length
            end
          end

          if mu.thumbnail_url
            begin
              # Add root url to relative urls.
              tu = URI(mu.thumbnail_url)
              abs_url = if tu.is_a?(URI::HTTP)
                tu
              else
                URI.join config.fetch('root_url'), tu
              end
              options.merge! :media_thumbnail_url => abs_url
            rescue URI::InvalidURIError
            end
          end

          Murlsh::failproof do
            if mu.via
              options.merge!(
                :via_type => 'text/html',
                :via_href => mu.via,
                :via_title => URI(mu.via).extend(Murlsh::URIDomain).domain
                )
            end
          end

          feed.add_entry mu.id, mu.title_stripped, mu.time, mu.url, options
        end

        @updated = feed.updated
        @body = feed.make
      end

    end

  end

end

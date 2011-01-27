require 'murlsh'

module Murlsh

  # Regenerate m3u file after a new audio url has been added.
  class AddPost50UpdateM3u < Plugin

    @hook = 'add_post'

    AudioContentTypes = %w{
      application/ogg
      audio/mpeg
      audio/ogg
      }

    OutputFile = 'm3u.m3u'

    def self.run(url, config)
      if AudioContentTypes.include?(url.content_type) or
        not File.exists?(OutputFile)

        Murlsh::openlock(OutputFile, 'w') do |f|
          f.write "# #{config['root_url']}\r\n\r\n"
          Murlsh::Url.all(:conditions =>
            ["content_type IN (?)", AudioContentTypes],
            :order => 'time DESC').each do |mu|
            f.write "#{mu.url}\r\n"
          end
        end
      end
    end

  end

end

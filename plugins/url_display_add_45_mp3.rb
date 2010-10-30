%w{
murlsh
}.each { |m| require m }

module Murlsh

  # Add Flash mp3 player to mp3 urls.
  class UrlDisplayAdd45Mp3 < Plugin

    @hook = 'url_display_add'

    def self.run(markup, url, config)
      if url.content_type == 'audio/mpeg'
        swf = 'swf/player_mp3_mini.swf'

        markup.object(
          :type => 'application/x-shockwave-flash',
          :data => swf,
          :width => 200,
          :height => 20) {
          markup.param(:name => 'bgcolor', :value => '#000000')
          markup.param(:name => 'FlashVars', :value => "mp3=#{url.url}")
          markup.param(:name => 'movie', :value => swf)
        }
      end
    end

  end

end

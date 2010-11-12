%w{
digest/md5

plumnailer

murlsh
}.each { |m| require m }

module Murlsh

  # Get thumbnail with plumnailer if not already set.
  class AddPre65DefaultThumb < Plugin

    @hook = 'add_pre'

    StorageDir = File.join(File.dirname(__FILE__), '..', 'public', 'img',
      'thumb')
    MaxWidth = 64

    def self.run(url, config)
      unless url.thumbnail_url
        Murlsh::failproof do
          chooser = Plumnailer::Chooser.new
          choice = chooser.choose(url.url)

          if choice
            choice.each do |i|
              i.resize_to_fit!(MaxWidth) if i.columns > MaxWidth
            end

            thumb_storage = Murlsh::ImgStore.new(StorageDir)

            stored_filename = thumb_storage.store_img_data(choice.to_blob)
            url.thumbnail_url = "img/thumb/#{CGI.escape(stored_filename)}"
          end
        end
      end
    end

  end

end

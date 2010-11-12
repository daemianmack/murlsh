%w{
cgi
digest/md5
open-uri
uri

RMagick

murlsh
}.each { |m| require m }

module Murlsh

  # Fetch images from urls and store them locally.
  class ImgStore

    def initialize(storage_dir, options={})
      @storage_dir = storage_dir
      @user_agent = options[:user_agent]
    end

    # Build headers to send with request.
    def headers
      result = {}
      result['User-Agent'] = @user_agent if @user_agent
      result
    end

    # Fetch an image from a url and store it locally.
    #
    # The filename will be the md5sum of the contents plus the original
    # extension.
    def store(url)
      open(url, headers) { |fin| store_img_data(fin.read) }
    end

    # Accept a blob of image data and store it locally.
    #
    # The filename will be the md5sum of the contents plus the original
    # extension.
    def store_img_data(img_data)
      md5sum = Digest::MD5.hexdigest(img_data)

      img = Magick::ImageList.new.from_blob(img_data)
      extension = ImgStore.format_to_extension(img.format)

      local_file = "#{md5sum}#{extension}"
      local_path = File.join(storage_dir, local_file)
      unless File.exists?(local_path)
        Murlsh::openlock(local_path, 'w') { |fout| fout.write(img_data) }
      end
      local_file
    end

    def self.format_to_extension(format)
      {
        'GIF' => '.gif',
        'JPEG' => '.jpg',
        'PNG' => '.png',
      }[format]
    end

    attr_reader :storage_dir
  end

end

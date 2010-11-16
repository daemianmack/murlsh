require 'cgi'
require 'digest/md5'
require 'open-uri'
require 'uri'

require 'RMagick'

require 'murlsh'

module Murlsh

  # Fetch images from urls and store them locally.
  class ImgStore

    # Fetch images from urls and store them locally.
    # Options:
    # * :user_agent - user agent to send with http requests
    def initialize(storage_dir, options={})
      @storage_dir = storage_dir
      @user_agent = options[:user_agent]
    end

    # Build headers to send with request.
    def headers
      result = {}
      result['User-Agent'] = @user_agent  if @user_agent
      result
    end

    # Fetch an image from a url and store it locally.
    #
    # The filename will be the md5sum of the contents plus the correct
    # extension.
    #
    # If a block is given the Magick::ImageList created will be yielded
    # before storage.
    def store_url(url, &block)
      open(url, headers) { |fin| store_img_data fin.read, &block }
    end

    # Accept a blob of image data and store it locally.
    #
    # The filename will be the md5sum of the contents plus the correct
    # extension.
    #
    # If a block is given the Magick::ImageList created will be yielded
    # before storage.
    def store_img_data(img_data, &block)
      img = Magick::ImageList.new.from_blob(img_data)
      yield img if block_given?
      store_img img
    end

    # Accept a Magick::ImageList and store it locally.
    #
    # The filename will be the md5sum of the contents plus the correct
    # extension.
    def store_img(img)
      img.extend(Murlsh::ImageList)  unless img.is_a?(Murlsh::ImageList)
      img_data = img.to_blob
      md5 = Digest::MD5.hexdigest(img_data)

      local_file = "#{md5}#{img.preferred_extension}"
      local_path = File.join(storage_dir, local_file)
      unless File.exists?(local_path)
        Murlsh::openlock(local_path, 'w') { |fout| fout.write img_data }
      end
      local_file
    end

    attr_reader :storage_dir
  end

end

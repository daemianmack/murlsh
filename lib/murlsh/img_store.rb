%w{
cgi
digest/md5
open-uri
uri

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
      extension = File.extname(URI(url).path)

      open(url, headers) do |fin|
        img_data = fin.read
        md5sum = Digest::MD5.hexdigest(img_data)
        local_file = "#{md5sum}#{extension}"
        local_path = File.join(storage_dir, local_file)
        unless File.exists?(local_path)
          Murlsh::openlock(local_path, 'w') { |fout| fout.write(img_data) }
        end
        local_file
      end
    end

    attr_reader :storage_dir
  end

end

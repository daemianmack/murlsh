%w{
cgi
open-uri
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
    def store(url)
      local_file = CGI.escape(url)
      local_path = File.join(storage_dir, local_file)
      open(url, headers) do |fin|
        open(local_path, 'w') { |fout| fout.write(fin.read) }
      end
      local_file
    end

    attr_reader :storage_dir
  end

end

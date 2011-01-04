require 'digest/md5'

module Murlsh

  module BuildMd5

    # Return the md5 sum of the result of the build method.
    def md5; Digest::MD5.hexdigest(build); end

  end

end

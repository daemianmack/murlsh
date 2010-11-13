require 'digest/md5'

module Murlsh

  # Magick::ImageList mixin.
  module ImageList

    # For each image, if the width or height is larger than max_side, resize so
    # that the longest side = max_side.
    def resize_down!(max_side)
      reject { |i| i.columns <= max_side and i.rows <= max_side }.each do |i|
        i.resize_to_fit!(max_side, max_side)
      end
    end

    # Return the hex MD5 sum of this image data.
    def md5; Digest::MD5.hexdigest(to_blob); end

    # Get the preferred extension for this image.
    def preferred_extension; FormatExtensions[self.format]; end

    FormatExtensions = {
      'GIF' => '.gif',
      'JPEG' => '.jpg',
      'PNG' => '.png',
    }

  end

end

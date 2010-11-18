require 'base64'

module Murlsh

  # Magick::ImageList mixin.
  module ImageList

    # For each image, if the width or height is larger than max_side, resize so
    # that the longest side = max_side.
    def resize_down!(max_side)
      each do |i|
        if i.columns > max_side or i.rows > max_side
          i.resize_to_fit! max_side, max_side
        end
        i.strip!
      end
    end

    # Get the preferred extension for this image.
    def preferred_extension; FormatExtensions[self.format]; end

    def data_uri; "data:#{mime_type};base64,#{Base64.encode64(to_blob)}"; end

    FormatExtensions = {
      'GIF' => '.gif',
      'JPEG' => '.jpg',
      'PNG' => '.png',
    }

  end

end

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

  end

end

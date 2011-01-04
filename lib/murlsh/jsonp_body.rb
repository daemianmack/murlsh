module Murlsh

  # Recent urls jsonp response builder.
  class JsonpBody < Murlsh::JsonBody

    # Recent urls jsonp response builder.
    def build
      if defined?(@body)
        @body
      else
        @body = "#{@req['callback']}(#{super})"
      end
    end

  end

end

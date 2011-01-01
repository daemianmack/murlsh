module Murlsh

  # Recent urls jsonp response builder.
  class JsonpBody < Murlsh::JsonBody

    # Recent urls jsonp response builder.
    def each; super { |json| yield "#{@req['callback']}(#{json})" }; end

  end

end

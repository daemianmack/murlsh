module Murlsh

  # URI mixin that adds method to get path and query string.
  module URIGetPathQuery

    # Return the path and query string.
    def get_path_query; path + (query ? "?#{query}" : ''); end

  end

end

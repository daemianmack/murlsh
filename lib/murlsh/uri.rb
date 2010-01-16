require 'uri'

# Extra methods added to URI class.
class URI::Generic

  # Return the domain.
  def domain
    if (host and (d = host[/[a-z\d-]+\.[a-z]{2,}(\.[a-z]{2})?$/]))
      d.downcase
    end
  end

  # Return the path and query string.
  def path_query; path + (query ? "?#{query}" : ''); end

end

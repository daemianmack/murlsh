require 'uri'

# Extra methods added to URI class.
class URI::Generic

  # Return the domain.
  def domain; host[/[a-z\d-]+\.[a-z]{2,}(\.[a-z]{2})?$/].downcase; end

  # Return the path and query string.
  def path_query; path + (query ? "?#{query}" : ''); end

end

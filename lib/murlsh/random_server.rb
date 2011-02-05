require 'rack'

require 'murlsh'

module Murlsh

  # Redirect to a random url from the database.
  class RandomServer

    include HeadFromGet

    # Redirect to a random url from the database.
    def get(req)
      choice = random_url.url
      Rack::Response.new "<a href=\"#{choice}\">#{choice}</a>", 302, {
        'Location' => choice }
    end

    # Select a random url from the database.
    def random_url
      Murlsh::Url.all(:limit => 1, :offset => rand(Murlsh::Url.count))[0]
    end

  end

end

require 'rack'

require 'murlsh'

module Murlsh

  # Redirect to a random url from the database.
  class RandomServer

    include HeadFromGet

    def initialize(config); @config = config; end

    # Redirect to a random url from the database.
    #
    # Redirect to root url if there are no urls.
    def get(req)
      if choice = random_url
        url = choice.url
      else
        url = config['root_url']
      end

      Rack::Response.new "<a href=\"#{url}\">#{url}</a>", 302, {
        'Location' => url }
    end

    # Select a random url from the database.
    #
    # Return nil if there are no urls.
    def random_url
      count = Murlsh::Url.count
      Murlsh::Url.first(:offset => rand(count))  if count > 0
    end

    attr_reader :config
  end

end

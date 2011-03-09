module Murlsh

  # Superclass for servers.
  class Server

    def initialize(config); @config = config; end

    attr_reader :config
  end

end

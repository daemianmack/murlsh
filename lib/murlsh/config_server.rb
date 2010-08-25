%w{
digest/sha1

json
rack
}.each { |m| require m }

module Murlsh

  # Serve a JSON subset of the configuration.
  #
  # Will include all config keys contained in the config key named config_js.
  class ConfigServer

    include HeadFromGet

    def initialize(config)
      @config_json =
        config.reject { |k,v| !config.fetch('config_js', []).
          include?(k) }.to_json

      @headers = {
        'Content-Type' => 'application/json',
        'ETag' => "\"#{Digest::SHA1.hexdigest(@config_json)}\"",
        'Last-Modified' => Time.now.httpdate
      }
    end

    # Serve a JSON subset of the configuration.
    def get(req); Rack::Response.new(@config_json, 200, @headers); end

  end

end

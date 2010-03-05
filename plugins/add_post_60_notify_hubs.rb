require 'murlsh'

module Murlsh

  # notify PubSubHubbub hubs that feed has been updated
  class NotifyHubs < Plugin

    Hook = 'add_post'

    def self.run(config)
      hubs = config.fetch('pubsubhubbub_hubs', [])

      unless hubs.empty?
        require 'rubygems'
        require 'eventmachine'
        require 'pubsubhubbub'

        feed_url = URI.join(config['root_url'], config['feed_file'])

        hubs.each do |hub|
          EventMachine.run {
            pub = EventMachine::PubSubHubbub.new(hub).publish(feed_url)

            pub.callback { EventMachine.stop  }
            pub.errback { EventMachine.stop }
          }
        end

      end

    end

  end

end

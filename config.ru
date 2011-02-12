$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'uri'
require 'yaml'

require 'rack'
require 'rack/cache'
require 'rack/rewrite'
require 'rack/throttle'

require 'murlsh'

config = YAML.load_file('config.yaml')

# use Rack::ShowExceptions
# no more than 1024 requests per day per ip
use Rack::Throttle::Daily, :max => 1024
if config.key?('cache_metastore') and config.key?('cache_entitystore')
  use Rack::Cache,
    :verbose => true,
    :metastore => config['cache_metastore'],
    :entitystore => config['cache_entitystore']
end
use Rack::ConditionalGet
use Murlsh::EtagAddEncoding
use Rack::Deflater
use Rack::Head
use Rack::ETag
use Murlsh::FarFutureExpires, :patterns => [
  %r{[\da-z]{32}\.(?:gif|jpe?g|png)$}i,
  %r{\.gen\.(css|js)$}
]

feed_url = URI.join(config.fetch('root_url'), config.fetch('feed_file'))
use Murlsh::MustRevalidate, :patterns => %r{^#{Regexp.escape(feed_url.path)}$}

use Rack::Static, :urls => %w{/css/ /img/ /js/}, :root => 'public'
use Rack::Static, :urls => %w{/m3u.m3u /podcast.rss}

use Rack::Rewrite do
  r301 '/atom.xml', feed_url.to_s
  r301 '/rss.xml', URI.join(config.fetch('root_url'), 'rss.rss').to_s
end

# use Rack::Lint

Dir['plugins/*.rb'].each { |p| require "./#{p}" }

run Murlsh::Dispatch.new(config)

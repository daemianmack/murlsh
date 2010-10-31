$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

%w{
yaml

rack/cache
rack/rewrite
rack/throttle

murlsh
}.each { |m| require m }

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
use Murlsh::FarFutureExpires, :patterns => %r{\.gen\.(css|js)$}

feed_url = URI.join(config.fetch('root_url'), config.fetch('feed_file'))
use Murlsh::MustRevalidate, :patterns => %r{^#{Regexp.escape(feed_url.path)}$}

use Rack::Static, :urls => %w{/css /img /js /swf}, :root => 'public'
use Rack::Static, :urls => %w{/atom.atom /podcast.rss /rss.rss}

use Rack::Rewrite do
  r301 '/atom.xml', feed_url.to_s
  r301 '/rss.xml', URI.join(config.fetch('root_url'), 'rss.rss').to_s
end

# use Rack::Lint

run Murlsh::Dispatch.new(config)

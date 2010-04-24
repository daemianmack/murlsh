$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

%w{
yaml

rack/cache

murlsh
}.each { |m| require m }

config = YAML.load_file('config.yaml')

# use Rack::ShowExceptions
use Rack::Cache,
  :verbose => true,
  :metastore => 'file:tmp/cache/rack/meta',
  :entitystore => 'file:tmp/cache/rack/body'
use Rack::ConditionalGet
use Murlsh::EtagAddEncoding
use Rack::Deflater
use Murlsh::FarFutureExpires, :patterns => %r{\.gen\.(css|js)$}

feed_path = URI.join(config.fetch('root_url'), config.fetch('feed_file')).path
use Murlsh::MustRevalidate, :patterns => %r{^#{Regexp.escape(feed_path)}$}

use Rack::Static, :urls => %w{/css /js /swf}, :root => 'public'
use Rack::Static, :urls => %w{/atom.xml /rss.xml}

# use Rack::Lint

run Murlsh::Dispatch.new(config)

$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'uri'
require 'yaml'

require 'active_record'
require 'rack'
require 'rack/cache'
require 'rack/contrib/jsonp'
require 'rack/rewrite'
require 'rack/throttle'

require 'murlsh'

config = YAML.load_file('config.yaml')

# for Heroku
db_config_file = File.join(File.dirname(__FILE__), 'config', 'database.yml')
if File.exist?(db_config_file)
  config['db'] = YAML.load_file(db_config_file)['production']
end

# use Rack::ShowExceptions
# no more than 1024 requests per day per ip
use Rack::Throttle::Daily, :max => 1024

if !config['cache_metastore'].to_s.empty? and
  !config['cache_entitystore'].to_s.empty?
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
use Murlsh::MustRevalidate, :patterns => [
  %r{^#{Regexp.escape(feed_url.path)}$},
  %r{^/(url)?$},
  %r{^/json\.json$},
  %r{^/m3u\.m3u$},
  %r{^/podcast\.rss$},
  %r{^/rss\.rss$},
  ]

use Rack::JSONP
use Rack::Static, :urls => %w{/css/ /img/ /js/}, :root => 'public'

use Rack::Rewrite do
  r301 '/atom.xml', feed_url.to_s
  r301 '/rss.xml', URI.join(config.fetch('root_url'), 'rss.rss').to_s
end

use ActiveRecord::ConnectionAdapters::ConnectionManagement

# use Rack::Lint

Dir['plugins/*.rb'].each { |p| require "./#{p}" }

run Murlsh::Dispatch.new(config)

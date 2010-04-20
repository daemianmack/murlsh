$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

%w{
yaml

rack/cache

murlsh
}.each { |m| require m }

# use Rack::ShowExceptions
use Rack::Cache,
  :verbose => true,
  :metastore => 'file:tmp/cache/rack/meta',
  :entitystore => 'file:tmp/cache/rack/body'
use Rack::ConditionalGet
use Murlsh::EtagAddEncoding
use Rack::Deflater
use Rack::Static, :urls => %w{/css /js /swf}, :root => 'public'
use Rack::Static, :urls => %w{/atom.xml /rss.xml}

config = YAML.load_file('config.yaml')

run Murlsh::Dispatch.new(config)

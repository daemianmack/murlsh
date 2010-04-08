$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

%w{
yaml

murlsh
}.each { |m| require m }

# use Rack::ShowExceptions
use Rack::ConditionalGet
use Murlsh::EtagAddEncoding
use Rack::Deflater

begin
  require 'rack/contrib' if Rack.version.to_f < 1.1
rescue LoadError
end

begin
  use Rack::ETag
rescue NameError
end

use Rack::Static, :urls => %w{/css /js /swf}, :root => 'public'
use Rack::Static, :urls => %w{/atom.xml /rss.xml}

config = YAML.load_file('config.yaml')

run Murlsh::Dispatch.new(config)

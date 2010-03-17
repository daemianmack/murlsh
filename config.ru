$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'murlsh'

require 'yaml'

# use Rack::ShowExceptions
use Rack::ConditionalGet
use Rack::Deflater
use Rack::Static, :urls => %w{/css /js /swf}, :root => 'public'
use Rack::Static, :urls => %w{/atom.xml}

config = YAML.load_file('config.yaml')

run Murlsh::Dispatch.new(config)

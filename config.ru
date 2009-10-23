$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'rubygems'
require 'murlsh'

# use Rack::ShowExceptions
use Rack::ConditionalGet
use Rack::Deflater
use Rack::Static, :urls => %w{/css /js /swf}, :root => 'public'
use Rack::Static, :urls => %w{/atom.xml}

run Murlsh::Dispatch.new

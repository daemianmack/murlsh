$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'murlsh'

use Rack::Static, :urls => %w{/atom.xml /css /js /swf}
# use Rack::ShowExceptions
run Murlsh::Dispatch.new

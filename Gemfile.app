# This Gemfile is for 'instances' of murlsh. It is not the Gemfile for the
# gem, but for installations of murlsh created with the 'murlsh' command.

require 'murlsh/version'

source :rubygems

gem 'murlsh', "= #{Murlsh::VERSION}"

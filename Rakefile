require 'rubygems'
require 'flog'

desc "Run flog on ruby and report on complexity."
task :flog do
  flog = Flog.new
  flog.flog_files('lib')
  flog.report
end

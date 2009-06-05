require 'rubygems'
require 'rake/testtask'
require 'flog'

desc "Run flog on ruby and report on complexity."
task :flog do
  flog = Flog.new
  flog.flog_files('lib')
  flog.report
end

desc "Run tests"
Rake::TestTask.new do |t|
  t.pattern = 'test/*_test.rb'
  t.verbose = true
  t.warning = true
end

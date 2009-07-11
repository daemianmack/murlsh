$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'murlsh'

require 'rubygems'
require 'rake/testtask'
require 'flog'

require 'yaml'
require 'sqlite3'

config = YAML.load_file('config.yaml')

desc "Test remote content type fetch for a URL and show errors."
task :content_type, :url do |t, args|
  puts Murlsh.get_content_type(args.url, :failproof => false)
end

namespace :db do

  desc "Check for duplicate URLs."
  task :dupcheck do
    db = SQLite3::Database.new(config.fetch('db_file'))
    db.results_as_hash = true
    h = {}
    db.execute("SELECT * FROM urls").each do |r|
      h[r['url']] = h.fetch(r['url'], []).push([r['id'], r['time']])
    end
    h.select { |k,v| v.size > 1 }.each do |k,v|
      puts k
      v.each { |id,time| puts "  #{id} #{time}" }
    end
  end

  desc "Create an empty database."
  task :init do
    puts "creating #{config.fetch('db_file')}"
    db = SQLite3::Database.new(config.fetch('db_file'))
    db.execute("CREATE TABLE urls (
      id INTEGER PRIMARY KEY,
      time TIMESTAMP,
      url TEXT,
      email TEXT,
      name TEXT,
      title TEXT,
      content_type TEXT);
      ")
  end

end

namespace :dreamhost do

  desc "Restart Passenger."
  task :restart do
    open('tmp/restart.txt', 'w') { |f| }
  end

end

desc "Run flog on ruby and report on complexity."
task :flog do
  flog = Flog.new
  flog.flog('lib')
  flog.report
end

desc "Run test suite."
Rake::TestTask.new do |t|
  t.pattern = 'test/*_test.rb'
  t.verbose = true
  t.warning = true
end

desc "Test remote title fetch for a URL and show errors."
task :title, :url do |t, args|
  puts Murlsh.get_title(args.url, :failproof => false)
end

namespace :user do

  desc "Add a new user."
  task :add do
    puts "adding to #{config.fetch('auth_file')}"
    username = ask(:username)
    email = ask(:email)
    password = ask(:password)

    Murlsh::Auth.new(config.fetch('auth_file')).add_user(username, email,
      password)
  end

end

desc "Validate XHTML."
task :validate do
  require 'cgi'
  require 'net/http'

  net_http = Net::HTTP.new('validator.w3.org', 80)
  #net_http.set_debug_output(STDOUT)

  check_url = config.fetch('root_url')

  print "validating #{check_url} : "

  net_http.start do |http|
    resp = http.request_head(
      "/check?uri=#{CGI::escape(check_url)}&charset=(detect+automatically)&doctype=Inline&group=0")
    result = resp['X-W3C-Validator-Status']
    errors = resp['X-W3C-Validator-Errors']
    warnings = resp['X-W3C-Validator-Warnings']

    puts "#{result} (#{errors} errors, #{warnings} warnings)"
  end

end

def ask(prompt)
  print "#{prompt}: "
  return STDIN.gets.chomp
end

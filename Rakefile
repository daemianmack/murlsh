$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

%w{
cgi
digest/md5
net/http
pp
uri
yaml

rubygems

flog
rake/testtask
sqlite3

murlsh
}.each { |d| require d }

config = YAML.load_file('config.yaml')

desc "Test remote content type fetch for a URL and show errors."
task :content_type, :url do |t, args|
  puts Murlsh.get_content_type(args.url, :failproof => false, :debug => STDOUT)
end

namespace :db do

  desc 'Delete the last url added.'
  task :delete_last_url do
    ActiveRecord::Base.establish_connection(:adapter => 'sqlite3',
      :database => config.fetch('db_file'))

    last = Murlsh::Url.find(:last, :order => 'time')
    pp last
    response = ask('Delete this url', '?')
    last.destroy if %w{y yes}.include?(response.downcase)
  end

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
      content_type TEXT,
      via TEXT);
      ")
  end

  desc 'Interact with the database.'
  task :shell do
    exec "sqlite3 #{config['db_file']}"
  end

end

directory 'tmp'

namespace :passenger do

  desc 'Restart Passenger.'
  task :restart => ['tmp'] do
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
  puts Murlsh.get_title(args.url, :failproof => false, :debug => STDOUT)
end

desc 'Try to fetch the title for a url and update it in the database.'
task :title_fetch, :url_id do |t, args|
  ActiveRecord::Base.establish_connection(:adapter => 'sqlite3',
    :database => config.fetch('db_file'))
  url = Murlsh::Url.find(args.url_id)
  puts "Url: #{url.url}"
  puts "Previous title: #{url.title}"
  url.title = Murlsh.get_title(url.url, :failproof => false)
  url.save
  puts "\nNew title: #{url.title}"
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

desc 'Generate a shell script that will post a new url.'
task :post_sh do
  puts <<EOS
#!/bin/sh

URL="$1"
AUTH="$2" # password can be passed as second parameter or hardcoded here

curl \\
  --data-urlencode "url=${URL}" \\
  --data-urlencode "auth=${AUTH}" \\
  #{config.fetch('root_url')}
EOS
end

# Concatenate some files and return the result as a string.
def cat(in_files, sep=nil)
  result = ''
  in_files.each do |fname|
    open(fname) do |h|
      while (line = h.gets) do; result << line; end
      result << sep if sep
    end
  end
  result
end

directory 'public/css'

namespace :css do

  desc 'Combine and compress css.'
  task :compress => ['public/css'] do
    combined = cat(config['css_files'].collect { |x| "public/#{x}" }, "\n")

    md5sum = Digest::MD5.hexdigest(combined)

    filename = "#{md5sum}.gen.css"

    out = "public/css/#{filename}"

    open(out, 'w') { |f| f.write(combined) }
    puts "generated #{out}"

    compressed_url = "css/#{filename}"

    unless config['css_compressed'] == compressed_url
      config['css_compressed'] = compressed_url
      open('config.yaml', 'w') { |f| YAML.dump(config, f) }
      puts "updated config with css_compressed = #{compressed_url}"
    end
  end

end

directory 'public/js'

namespace :js do

  desc 'Combine and compress javascript.'
  task :compress => ['public/js'] do
    combined = cat(config['js_files'].collect { |x| "public/#{x}" } )

    compressed = Net::HTTP.post_form(
      URI.parse('http://closure-compiler.appspot.com/compile'), {
      'compilation_level' => 'SIMPLE_OPTIMIZATIONS',
      'js_code' => combined,
      'output_format' => 'text',
      'output_info' => 'compiled_code',
      }).body

    md5sum = Digest::MD5.hexdigest(compressed)

    filename = "#{md5sum}.gen.js"

    out = "public/js/#{filename}"

    open(out, 'w') { |f| f.write(compressed) }
    puts "generated #{out}"

    compressed_url = "js/#{filename}"

    unless config['js_compressed'] == compressed_url
      config['js_compressed'] = compressed_url
      open('config.yaml', 'w') { |f| YAML.dump(config, f) }
      puts "updated config with js_compressed = #{compressed_url}"
    end
  end

end

def ask(prompt, sep=':')
  print "#{prompt}#{sep} "
  return STDIN.gets.chomp
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = 'murlsh'
    gemspec.summary = 'url sharing site framework'
    gemspec.description = 'url sharing site framework with easy adding, title lookup, atom feed, thumbnails and embedding'
    gemspec.email = 'matthewm@boedicker.org'
    gemspec.homepage = 'http://github.com/mmb/murlsh'
    gemspec.authors = ['Matthew M. Boedicker']
    gemspec.executables = %w{murlsh}

    %w{
      activerecord 2.3.4
      bcrypt-ruby 2.1.2
      builder 2.1.2
      hpricot 0.8.1
      htmlentities 4.2.0
      rack 1.0.0
      sqlite3-ruby 1.2.1
     }.each_slice(2) { |g,v| gemspec.add_dependency(g, ">= #{v}") }

  end
rescue LoadError
  puts 'Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com'
end

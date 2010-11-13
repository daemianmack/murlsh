$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'cgi'
require 'digest/md5'
require 'net/http'
require 'pp'
require 'uri'
require 'yaml'

require 'RMagick'
require 'sqlite3'

require 'murlsh'

def gem_not_found(gem_name)
  puts "#{gem_name} not found, install it with: gem install #{gem_name}"
end

config = YAML.load_file('config.yaml')

desc 'Initialize a new installation.'
task :init => %w{db:init user:add compress} do
  puts <<-eos

Things you might want to do now:

- visit #{config['root_url']} in a browser
- 'rake post_sh > url_post.sh' to generate a shell script for posting urls

eos
end

desc 'Combine and compress static files.'
task :compress => %w{css:compress js:compress}

desc 'Test remote content type fetch for a URL and show errors.'
task :content_type, :url do |t, args|
  puts URI(args.url).extend(Murlsh::UriAsk).content_type(:failproof => false,
    :debug => STDOUT)
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

  desc 'Check for duplicate URLs.'
  task :dupcheck do
    db = SQLite3::Database.new(config.fetch('db_file'))
    db.results_as_hash = true
    h = {}
    db.execute('SELECT * FROM urls').each do |r|
      h[r['url']] = h.fetch(r['url'], []).push([r['id'], r['time']])
    end
    h.select { |k,v| v.size > 1 }.each do |k,v|
      puts k
      v.each { |id,time| puts "  #{id} #{time}" }
    end
  end

  desc 'Create an empty database.'
  task :init do
    puts "creating #{config.fetch('db_file')}"
    db = SQLite3::Database.new(config.fetch('db_file'))
    db.execute('CREATE TABLE urls (
      id INTEGER PRIMARY KEY,
      time TIMESTAMP,
      url TEXT,
      email TEXT,
      name TEXT,
      title TEXT,
      content_length INTEGER,
      content_type TEXT,
      via TEXT,
      thumbnail_url TEXT);
      ')
  end

  desc 'Interact with the database.'
  task :shell do
    exec "sqlite3 #{config['db_file']}"
  end

end

directory 'tmp'

namespace :passenger do

  desc 'Restart Passenger.'
  task :restart => %w{compress tmp} do
    open('tmp/restart.txt', 'w') { |f| }
  end

end

desc 'Run flog on ruby and report on complexity.'
task :flog do
  begin
    require 'flog'

    flog = Flog.new
    flog.flog('lib')
    flog.report
  rescue LoadError
    gem_not_found('flog')
  end
end

desc 'Run test suite.'
begin
  require 'spec/rake/spectask'

  Spec::Rake::SpecTask.new('test') do |t|
    t.spec_files = FileList['spec/*_spec.rb']
    t.spec_opts = %w{--color}
    # list of places to check for unicode_formatter.rb and use it if found
    %w{unicode_formatter.rb}.map { |x| File.expand_path(x) }.each do |f|
      if File.exists?(f)
        t.spec_opts.push(*%W{--require #{f} --format UnicodeFormatter})
        break
      end
    end
    t.verbose = true
    t.warning = true
  end
rescue LoadError
  task :test do
    gem_not_found('rspec')
  end
end

desc 'Test remote title fetch for a URL and show errors.'
task :title, :url do |t, args|
  puts URI(args.url).extend(Murlsh::UriAsk).title(:failproof => false,
    :debug => STDOUT)
end

desc 'Try to fetch the title for a url and update it in the database.'
task :title_fetch, :url_id do |t, args|
  ActiveRecord::Base.establish_connection(:adapter => 'sqlite3',
    :database => config.fetch('db_file'))
  url = Murlsh::Url.find(args.url_id)
  puts "Url: #{url.url}"
  puts "Previous title: #{url.title}"
  url.title = URI(url.url).extend(Murlsh::UriAsk).title(:failproof => false)
  url.save
  puts "\nNew title: #{url.title}"
end

namespace :user do

  desc 'Add a new user.'
  task :add do
    puts "adding to #{config.fetch('auth_file')}"
    username = ask(:username)
    email = ask(:email)
    password = ask(:password)

    Murlsh::Auth.new(config.fetch('auth_file')).add_user(username, email,
      password)
  end

end

# Validate a document with the W3C validation service.
def validate(check_url, options={})
  opts = {
    :validator_host => 'validator.w3.org',
    :validator_port => 80,
    :validator_path =>
      "/check?uri=#{CGI::escape(check_url)}&charset=(detect+automatically)&doctype=Inline&group=0",
  }.merge(options)

  net_http = Net::HTTP.new(opts[:validator_host], opts[:validator_port])
  # net_http.set_debug_output(STDOUT)

  net_http.start do |http|
    resp = http.request_head(opts[:validator_path])
    result = {
      :response => resp
    }
    if Net::HTTPSuccess === resp
      result.merge!(
        :status =>  resp['X-W3C-Validator-Status'],
        :errors => resp['X-W3C-Validator-Errors'],
        :warnings => resp['X-W3C-Validator-Warnings']
      )
    end
    result
  end

end

namespace :validate do

  desc 'Validate HTML.'
  task :html do
    check_url = config['root_url']
    print "validating #{check_url} : "
    result = validate(check_url)
    if Net::HTTPSuccess === result[:response]
      puts "#{result[:status]} (#{result[:errors]} errors, #{result[:warnings]} warnings)"
    else
      puts result[:response]
    end
  end

end

desc 'Generate a shell script that will post a new url.'
task :post_sh do
  puts <<EOS
#!/bin/sh

URL="$1"
VIA="$2"
AUTH="$3" # password can be passed as third parameter or hardcoded here

curl \\
  --data-urlencode "url=${URL}" \\
  --data-urlencode "auth=${AUTH}" \\
  --data-urlencode "via=${VIA}" \\
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
    combined = cat(config['css_files'].map { |x| "public/#{x}" }, "\n")

    md5sum = Digest::MD5.hexdigest(combined)

    filename = "#{md5sum}.gen.css"

    out = "public/css/#{filename}"

    open(out, 'w') { |f| f.write(combined) }
    puts "generated #{out}"

    compressed_url = "css/#{filename}"

    unless config['css_compressed'] == compressed_url
      config['css_compressed'] = compressed_url
      config.extend(Murlsh::YamlOrderedHash)
      open('config.yaml', 'w') { |f| YAML.dump(config, f) }
      puts "updated config with css_compressed = #{compressed_url}"
    end
  end

end

directory 'public/js'

namespace :js do

  MURLSH_JS = %w{public/js/js.js}

  desc 'Combine and compress javascript.'
  task :compress => ['public/js'] do
    combined = cat(config['js_files'].map { |x| "public/#{x}" } )

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
      config.extend(Murlsh::YamlOrderedHash)
      open('config.yaml', 'w') { |f| YAML.dump(config, f) }
      puts "updated config with js_compressed = #{compressed_url}"
    end
  end

  desc 'Run javascript through jslint.'
  task :jslint do
    MURLSH_JS.each do |jsf|
      puts jsf
      puts `rhino http://www.jslint.com/rhino/jslint.js #{jsf}`
    end
  end

  desc "Run javascript through Google's Closure Linter."
  task :gjslint do
    MURLSH_JS.each do |jsf|
      puts jsf
      puts `gjslint #{jsf}`
    end
  end

end

namespace :thumb do

  desc 'Check that local thumbnails in database are consistent with filesystem.'
  task :check do
    ActiveRecord::Base.establish_connection(:adapter => 'sqlite3',
      :database => config.fetch('db_file'))
    Murlsh::Url.all(
      :conditions => "thumbnail_url like 'img/thumb/%'").each do |u|
      identity = "url #{u.id} (#{u.url})"

      path = File.join(%w{public}.concat(File.split(u.thumbnail_url)))
      if File.readable?(path)
        img_data = open(path) { |f| f.read }

        unless img_data.empty?
          img = Magick::ImageList.new.from_blob(img_data).extend(
            Murlsh::ImageList)

          ext = File.extname(path)
          expected_ext = img.preferred_extension
          if ext != expected_ext
            puts "#{identity} thumbnail #{path} has an extension of '#{ext}' but is actually a '#{expected_ext}'"

          end
        else
          puts "#{identity} thumbnail #{path} is empty"
        end
      else
        puts "#{identity} thumbnail #{path} does not exist or is not readable"
      end
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

    # gemspec.signing_key = '/home/mmb/src/keys/gem-private_key.pem'
    # gemspec.cert_chain = %w{/home/mmb/src/keys/gem-public_cert.pem}

    %w{
      activerecord >= 2.3.4
      bcrypt-ruby >= 2.1.2
      builder >= 2.1.2
      flickraw >= 0.8.3
      hpricot >= 0.8.1
      htmlentities >= 4.2.0
      json >= 1.2.3
      plumnailer >= 0.0.4
      push-notify >= 0.1.0
      rack >= 1.0.0
      rack-cache >= 0.5.2
      rack-rewrite >= 1.0.2
      rack-throttle >= 0.3.0
      rmagick >= 1.15.14
      sqlite3-ruby >= 1.2.1
      tinyatom >= 0.2.0
      twitter >= 0.9.12
      vimeo >= 1.2.2
      }.each_slice(3) { |g,o,v| gemspec.add_dependency(g, "#{o} #{v}") }
    %w{
      flog >= 2.5.0
      rspec ~> 1.3
      }.each_slice(3) do |g,o,v|
      gemspec.add_development_dependency(g, "#{o} #{v}")
    end
  end
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end

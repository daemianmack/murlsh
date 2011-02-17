source :rubygems

# This does not use 'gemspec' because it creates a Gemfile.lock that treats
# murlsh as a "gem" and will not work on Heroku, which sees murlsh as an
# "app".

# Dependencies duplicated in gemspec and here until a better solution is
# found.

%w{
  activerecord >= 2.3.4
  aws-s3 ~> 0.6
  bcrypt-ruby >= 2.1.2
  builder > 0
  htmlentities >= 4.2.0
  json >= 1.2.3
  nokogiri ~> 1.0
  plumnailer >= 0.1.3
  postrank-uri ~> 1.0
  public_suffix_service ~> 0.0
  push-notify >= 0.1.0
  rack >= 1.0.0
  rack-cache >= 0.5.2
  rack-rewrite >= 1.0.2
  rack-throttle >= 0.3.0
  rmagick >= 1.15.14
  rmail ~> 1.0
  sqlite3 ~> 1.3
  tinyatom >= 0.3.4
  treetop ~> 1.4
  twitter >= 0.9.12
  }.each_slice(3) { |g,o,v| gem g, "#{o} #{v}" }

group :development do
  %w{
    fakeweb ~> 1.3
    flog >= 2.5.0
    rack-test ~> 0.5
    rspec ~> 2.0
    }.each_slice(3) { |g,o,v| gem g, "#{o} #{v}" }
end

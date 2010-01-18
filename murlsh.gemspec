# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{murlsh}
  s.version = "0.5.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Matthew M. Boedicker"]
  s.date = %q{2010-01-17}
  s.default_executable = %q{murlsh}
  s.description = %q{url sharing site framework with easy adding, title lookup, atom feed, thumbnails and embedding}
  s.email = %q{matthewm@boedicker.org}
  s.executables = ["murlsh"]
  s.extra_rdoc_files = [
    "README.textile"
  ]
  s.files = [
    ".gitignore",
     ".htaccess",
     "COPYING",
     "README.textile",
     "Rakefile",
     "VERSION",
     "bin/murlsh",
     "config.ru",
     "config.yaml",
     "lib/murlsh.rb",
     "lib/murlsh/atom_feed.rb",
     "lib/murlsh/auth.rb",
     "lib/murlsh/dispatch.rb",
     "lib/murlsh/doc.rb",
     "lib/murlsh/failproof.rb",
     "lib/murlsh/markup.rb",
     "lib/murlsh/openlock.rb",
     "lib/murlsh/plugin.rb",
     "lib/murlsh/sqlite3_adapter.rb",
     "lib/murlsh/time.rb",
     "lib/murlsh/uri.rb",
     "lib/murlsh/uri_ask.rb",
     "lib/murlsh/url.rb",
     "lib/murlsh/url_body.rb",
     "lib/murlsh/url_server.rb",
     "lib/murlsh/xhtml_response.rb",
     "murlsh.gemspec",
     "plugins/hostrec_redundant.rb",
     "plugins/hostrec_skip.rb",
     "plugins/lookup_content_type_title.rb",
     "plugins/update_feed.rb",
     "public/css/jquery.jgrowl.css",
     "public/css/screen.css",
     "public/js/jquery-1.4.min.js",
     "public/js/jquery.cookie.js",
     "public/js/jquery.jgrowl_compressed.js",
     "public/js/js.js",
     "public/swf/player_mp3_mini.swf",
     "test/atom_feed_test.rb",
     "test/auth_test.rb",
     "test/markup_test.rb",
     "test/uri_ask_test.rb",
     "test/uri_test.rb",
     "test/xhtml_response_test.rb"
  ]
  s.homepage = %q{http://github.com/mmb/murlsh}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{url sharing site framework}
  s.test_files = [
    "test/xhtml_response_test.rb",
     "test/uri_ask_test.rb",
     "test/markup_test.rb",
     "test/uri_test.rb",
     "test/atom_feed_test.rb",
     "test/auth_test.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activerecord>, [">= 2.3.4"])
      s.add_runtime_dependency(%q<bcrypt-ruby>, [">= 2.1.2"])
      s.add_runtime_dependency(%q<builder>, [">= 2.1.2"])
      s.add_runtime_dependency(%q<hpricot>, [">= 0.8.1"])
      s.add_runtime_dependency(%q<htmlentities>, [">= 4.2.0"])
      s.add_runtime_dependency(%q<rack>, [">= 1.0.0"])
      s.add_runtime_dependency(%q<sqlite3-ruby>, [">= 1.2.1"])
    else
      s.add_dependency(%q<activerecord>, [">= 2.3.4"])
      s.add_dependency(%q<bcrypt-ruby>, [">= 2.1.2"])
      s.add_dependency(%q<builder>, [">= 2.1.2"])
      s.add_dependency(%q<hpricot>, [">= 0.8.1"])
      s.add_dependency(%q<htmlentities>, [">= 4.2.0"])
      s.add_dependency(%q<rack>, [">= 1.0.0"])
      s.add_dependency(%q<sqlite3-ruby>, [">= 1.2.1"])
    end
  else
    s.add_dependency(%q<activerecord>, [">= 2.3.4"])
    s.add_dependency(%q<bcrypt-ruby>, [">= 2.1.2"])
    s.add_dependency(%q<builder>, [">= 2.1.2"])
    s.add_dependency(%q<hpricot>, [">= 0.8.1"])
    s.add_dependency(%q<htmlentities>, [">= 4.2.0"])
    s.add_dependency(%q<rack>, [">= 1.0.0"])
    s.add_dependency(%q<sqlite3-ruby>, [">= 1.2.1"])
  end
end


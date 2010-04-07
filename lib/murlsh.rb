Dir.glob(File.join(File.dirname(__FILE__), 'murlsh', '*.rb')).
  map { |f| File.join('murlsh', File.basename(f, '.rb')) }.
  sort.
  each { |m| require m }

require 'fileutils'

require 'murlsh'

module Murlsh

  MurlshRoot = File.join(File.dirname(__FILE__), '..', '..')

  module_function

  # Install a murlsh site to a web directory.
  #
  # Copies files that are different per-site to make a site instance.
  def install(dest_dir)
    Murlsh.cp_r_safe(
      %w{
        .htaccess
        Rakefile
        config.ru
        config.yaml
        db/
        plugins/
        public/
        Gemfile.app
      }.map { |x| File.join(MurlshRoot, x) }, dest_dir, :verbose => true)

    File.rename(
      File.join(dest_dir, 'Gemfile.app'),
      File.join(dest_dir, 'Gemfile'))

    FileUtils.mkdir_p(File.join(dest_dir, 'tmp'), :verbose => true)
  end

end

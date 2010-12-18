require 'digest/md5'

require 'active_record'

require 'murlsh'

module Murlsh

  # Base class for importers.
  class Importer

    def initialize(config); @config = config; end

    # Import urls from a source.
    def import(source); end

    # Add a url to the database.
    def add_url(time, url, email, username, via)
      mu = Murlsh::Url.new do |u|
        u.time = time
        u.url = url
        u.email = Digest::MD5.hexdigest(email)
        u.name = username
        u.via = via
      end

      before(mu)

      begin
        # Validate before and after add_pre plugins because they can change
        # the data.
        raise ActiveRecord::RecordInvalid.new(mu)  unless mu.valid?
        Murlsh::Plugin.hooks('add_pre') { |p| p.run mu, config }
        mu.save!
        Murlsh::Plugin.hooks('add_post') { |p| p.run mu, config }
        success(mu)
      rescue ActiveRecord::RecordInvalid => error
        error(mu, error)
      end
    end

    # Do something before adding each url.
    def before(murlsh_url); puts murlsh_url.url; end

    # Do something after each successfully added url.
    def success(murlsh_url); puts '  ok'; end

    # Do something after each url that errors on add.
    def error(murlsh_url, error); puts "  #{error}"; end

    # Do something after each skipped url.
    def skipped(url); puts '  skipped'; end

    attr_reader :config
  end

end

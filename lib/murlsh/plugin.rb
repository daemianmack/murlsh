module Murlsh

  # Superclass for plugins. How plugins are registered.
  #
  # Hooks:
  # * add_pre - called before a new url is saved
  #   run arguments (url, config hash)
  # * add_post - called after a new url is saved
  #   run arguments (config hash)
  # * avatar - called to get an avatar url from an email md5 sum
  #   run arguments (avatar url, url, config hash)
  # * store_asset - store an asset somewhere where it can be loaded by url
  #   run arguments (name, data, config hash)
  # * url_display_add - called to display additional information after urls
  #   run arguments (markup builder, url, config hash)
  class Plugin

    # Called when a plugin class inherits from this class (the way plugins
    # are registered).
    def self.inherited(child)
      registered << child
    end

    # Get registered plugins by hook (add_pre, add_post, etc.)
    def self.hooks(name)
      matches = registered.find_all { |p| p.hook == name }.
        sort { |a,b| a.to_s <=> b.to_s }

      if block_given?
        matches.each { |p| yield p }
      end
      matches
    end

    @registered = []
    class << self;
      attr_reader :hook
      attr_reader :registered
    end

  end

end

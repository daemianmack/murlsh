module Murlsh

  # Superclass for plugins. How plugins are registered.
  # 
  # Hooks:
  #
  # add_pre - called before a new url is saved
  #   run arguments (url, config hash)
  # add_post - called after a new url is saved
  #   run arguments (config hash)
  class Plugin

    # Called when a plugin class inherits from this class (the way plugins
    # are registered).
    def self.inherited(child)
      registered << child
    end

    # Get registered plugins by hook (add_pre, add_post, etc.)
    def self.hooks(name)
      matches = registered.select { |p| p::Hook == name }.
        sort { |a,b| a.to_s <=> b.to_s }

      if block_given?
        matches.each { |p| yield p }
      end
      matches
    end

    @registered = []
    class << self; attr_reader :registered end

  end

end

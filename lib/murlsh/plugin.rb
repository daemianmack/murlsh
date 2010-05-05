module Murlsh

  # Superclass for plugins. How plugins are registered.
  #
  # Hooks:
  # * add_pre - called before a new url is saved
  #   run arguments (url, config hash)
  # * add_post - called after a new url is saved
  #   run arguments (config hash)
  # * hostrec - called to post process the domain that shows after links
  #   run arguments (domain, url, title)
  # * html_parse - called to parse HTML using something like Hpricot or Nokogiri
  #   run arguments (parseable)
  # * time - called to convert the time of a post into a string for display
  #   run arguments (time)
  # * via - called to convert a via url into a string for display
  #   run arguments (via url)
  class Plugin

    # Called when a plugin class inherits from this class (the way plugins
    # are registered).
    def self.inherited(child)
      registered << child
    end

    # Get registered plugins by hook (add_pre, add_post, etc.)
    def self.hooks(name)
      matches = registered.select { |p| p.hook == name }.
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

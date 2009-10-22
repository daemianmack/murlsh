module Murlsh

  class Plugin

    def self.inherited(child)
      registered << child
    end

    def self.hooks(name)
      matches = registered.select { |p| p::Hook == name }

      if block_given?
        matches.each { |p| yield p }
      end
      matches
    end

    @registered = []
    class << self; attr_reader :registered end

  end

end

%w{
murlsh
}.each { |m| require m }

module Murlsh

  # show the time as the fuzzy amount of time that has elapsed since then
  class Time50Ago < Plugin

    @hook = 'time'

    def self.run(time); time.extend(Murlsh::TimeAgo).ago if time; end

  end

end

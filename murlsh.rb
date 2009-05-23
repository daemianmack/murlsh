require 'hostrec'

module Murlsh

  class Url
    include HostRec

    def initialize(d={})
      d.each_pair { |k,v| send("#{k}=", v) if respond_to?("#{k}=") }
    end

    def same_author?(other)
      other and other.email and other.name and
        email and name and email == other.email and name == other.name
    end

    attr_accessor :id
    attr_accessor :time
    attr_accessor :url
    attr_accessor :email
    attr_accessor :name
    attr_accessor :title
  end

end

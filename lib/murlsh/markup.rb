require 'rubygems'
require 'builder'

module Murlsh

  class Markup < Builder::XmlMarkup

    def javascript(sources, options={})
      (sources.respond_to?(:each) ? sources : [sources]).each do |src|
        script('', :type => 'text/javascript',
          :src => "#{options[:prefix]}#{src}")
      end
    end

  end

end

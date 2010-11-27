require 'nokogiri'

require 'murlsh'

module Murlsh

  # Parse HTML with Nokogiri and return a Nokogiri doc.
  class HtmlParse50Nokogiri < Plugin

    @hook = 'html_parse'

    def self.run(x); Nokogiri(x); end

  end

end

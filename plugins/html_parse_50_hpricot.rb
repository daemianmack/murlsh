%w{
hpricot
}.each { |m| require m }

module Murlsh

  # Parse HTML with Hpricot and return an Hpricot doc.
  class HtmlParse50Hpricot < Plugin

    @hook = 'html_parse'

    def self.run(x)
      Hpricot(x)
      # Nokogiri(x) also works.
    end

  end

end

require 'rubygems'
require 'hpricot'

module Murlsh

  # Hpricot:Doc mixin.
  module Doc

    # Get the character set of the document.
    def charset
      %w{content-type Content-Type}.each do |ct|
        content_type = at("meta[@http-equiv='#{ct}']")
        unless content_type.nil?
          content = content_type['content']
          unless content.nil?
            charset = content[/charset=([\w_.:-]+)/, 1]
            return charset if charset
          end
        end
      end
      nil
    end

    # Find the title of the document.
    def title
      %w{//html/head/title //head/title //html/title //title}.each do |xpath|
        return (self/xpath).first.inner_html unless (self/xpath).first.nil?
      end
      nil
    end

  end

end

require 'uri'

require 'active_record'

module Murlsh

  # URL ActiveRecord.
  class Url < ActiveRecord::Base
    validates_format_of :url, :with => URI.regexp

    # Get the title of this url.
    def title
      ta = read_attribute(:title)
      ta = nil if ta and ta.empty?
      
      ua = read_attribute(:url)
      ua = nil if ua and ua.empty?

      ta || ua || 'title missing'
    end

    # Title with whitespace compressed and leading and trailing whitespace
    # stripped.
    def title_stripped; title.strip.gsub(/\s+/, ' '); end

    # Return true if this url has the same author as another url.
    def same_author?(other)
      other and other.email and other.name and
        email and name and email == other.email and name == other.name
    end

  end

end

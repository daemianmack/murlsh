require 'cgi'
require 'digest/md5'
require 'open-uri'
require 'uri'

require 'nokogiri'

require 'murlsh'

module Murlsh

  # Importer for Netscape bookmark file format.
  class BookmarksImporter < Importer

    def initialize(config, email, username)
      super(config)
      @email, @username = email, username
    end

    # Import urls from a Netscape bookmark file source.
    #
    # Source can be a URL or local file path.
    def import(source)
      doc = Nokogiri::HTML(open(source))

      doc.xpath('//dt').each do |dt|
        unless (a = dt.xpath('a')).empty?
          url = a[0]['href']

          if a[0]['private'] != '0'
            skipped(url)
            next
          end

          # extract via urls from text like 'via http://'
          text = dt.xpath('(following-sibling::dd/text())[1]')
          via = CGI::unescapeHTML(text.to_s).strip.chomp(')')[
            %r{via\s+([^\s]+)}, 1]
          via_url = (via and via[URI.regexp]) ? via : nil

          add_url(Time.at(a[0]['add_date'].to_i).gmtime, url, email, username,
            via_url)
        end
      end
    end

    attr_reader :email
    attr_reader :username
  end

end

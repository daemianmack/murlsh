require 'uri'

require 'murlsh'

module Murlsh

  # Google Code project page titles are not very descriptive so add summary
  # from page.
  class AddPre60GoogleCodeTitle < Plugin

    @hook = 'add_pre'

    GoogleCodeRe = %r{^http://code\.google\.com/p/[\w-]+/$}i

    def self.run(url, config)
      if url.url[GoogleCodeRe]
        url.ask.doc.xpath_search("//a[@id='project_summary_link']") do |node|
          summary = node ? node.inner_html : nil
          url.title << " - #{url.ask.decode(summary)}"  unless not summary or
            summary.empty?
        end
      end
    end

  end

end

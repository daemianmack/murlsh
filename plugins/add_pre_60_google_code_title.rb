%w{
murlsh
}.each { |m| require m }

module Murlsh

  # Google Code project page titles are not very descriptive so add summary
  # from page
  class AddPre60GoogleCodeTitle < Plugin

    @hook = 'add_pre'

    def self.run(url, config)
      if url.url[%r{^http://code\.google\.com/p/[\w-]+/$}]
        puts 'xxx'
        ask = URI(url.url).extend(Murlsh::UriAsk)
        ask.doc.xpath_search("//a[@id='project_summary_link']") do |node|
          summary = node ? node.inner_html : nil
          url.title << " - #{ask.decode(summary)}" unless !summary or
            summary.empty?
        end
      end
    end

  end

end

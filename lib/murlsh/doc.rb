module Murlsh

  # Nokogiri doc mixin.
  module Doc

    # Check a list of xpaths in order and yield and return the node matching
    # the first one that is not nil
    def xpath_search(xpaths)
      Array(xpaths).each do |xpath|
        selection = (self/xpath).first
        if selection; return (yield selection); end
      end
      nil
    end

    # Get the title of the document.
    def title
      xpath_search(%w{
        //html/head/title
        //head/title
        //html/title
        //title
        }) { |node| node.inner_html }
    end

    # Get the meta description of the document.
    def description
      xpath_search(
        "//html/head/meta[@name='description']"
        ) { |node| node['content'] }
    end

  end

end

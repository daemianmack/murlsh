module Murlsh

  class UrlResultSet

    def initialize(conditions, page, per_page)
      @conditions, @page, @per_page = conditions, page, per_page
      @order = 'time DESC'
    end

    def total_entries
      @total_entries ||= Murlsh::Url.count(:conditions => conditions)
    end

    def total_pages
      @total_pages ||= [(total_entries / per_page.to_f).ceil, 1].max
    end

    def offset; @offset ||= (page - 1) * per_page; end

    def last_update
      # activerecord maximum doesn't seem to work with order
      if defined?(@last_update)
        @last_update
      else
        @last_update = Murlsh::Url.all(:select => 'updated_at',
        :conditions => conditions, :order => order, :limit => per_page,
        :offset => offset).compact.map(&:updated_at).max
      end
    end

    def results
      Murlsh::Url.all(:conditions => conditions, :order => order,
        :limit => per_page, :offset => offset)
    end

    def prev_page; @prev_page ||= page - 1  if (2..total_pages) === page; end

    def next_page; @next_page ||= page + 1  if page < total_pages; end

    attr_reader :conditions
    attr_reader :page
    attr_reader :per_page
    attr_reader :order
  end

end

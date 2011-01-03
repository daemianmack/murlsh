module Murlsh

  # Search conditions builder for ActiveRecord conditions.
  class SearchConditions

    def initialize(q); @q = q; end

    # Search conditions builder for ActiveRecord conditions.
    def conditions
      if q
        search_cols = %w{name title url}
        [search_cols.map { |x| "MURLSHMATCH(#{x}, ?)" }.join(' OR ')].push(
          *[q] * search_cols.size)
      else
        []
      end
    end

    attr_accessor :q
  end

end

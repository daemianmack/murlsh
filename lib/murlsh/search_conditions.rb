module Murlsh

  # Search conditions builder for ActiveRecord conditions.
  module SearchConditions

    # Search conditions builder for ActiveRecord conditions.
    def search_conditions
      if @q
        search_cols = %w{name title url}
        [search_cols.map { |x| "MURLSHMATCH(#{x}, ?)" }.join(' OR ')].push(
          *[@q] * search_cols.size)
      else
        []
      end
    end

  end

end

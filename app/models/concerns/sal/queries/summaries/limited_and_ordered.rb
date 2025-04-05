module SAL::Queries::Summaries::LimitedAndOrdered
  extend ActiveSupport::Concern

  private

    LIMITED_AND_ORDERED_CTE_NAME = 'limited_and_ordered'.freeze

    def limited_and_ordered_tbl
      Arel::Table.new(LIMITED_AND_ORDERED_CTE_NAME)
    end

    def order_by(default:)
      @order_by&.join(" ").presence || default
    end

    # when there are both rows and columns, sort in descending order by the row total (in the total column)
    def limited_and_ordered_cte_for_rows_and_cols
      with_total_column_tbl
        .project(Arel.star)
        .order(order_by(default: "#{self.class::TOTAL_COL_NAME} DESC"))
    end

    def limited_and_ordered_cte_for_only_rows
      initial_query_tbl
        .project(Arel.star)
        .order(order_by(default: "2 DESC"))
    end

    def limited_and_ordered_cte
      cte = if has_rows_and_cols?
              limited_and_ordered_cte_for_rows_and_cols
            elsif has_rows?
              limited_and_ordered_cte_for_only_rows
            end

      cte.take(@row_limit).skip(@offset)
    end

    def limited_and_ordered_for_with
      Arel::Nodes::As.new(limited_and_ordered_tbl, limited_and_ordered_cte)
    end

end

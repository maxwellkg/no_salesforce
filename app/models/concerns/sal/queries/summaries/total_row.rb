module SAL::Queries::Summaries::TotalRow
  extend ActiveSupport::Concern

  private

    TOTAL_ROW_CTE_NAME = 'total_row'.freeze

    def total_row_tbl
      Arel::Table.new(TOTAL_ROW_CTE_NAME)
    end

    def total_row_cte
      # if rows and columns, use with_total_column_cte
      # else use the initial query
      from_tbl = has_rows_and_cols? ? with_total_column_tbl : initial_query_tbl

      # select the sum for every column
      #
      # if the summary includes columns, then we will gather the sum for each one
      #
      # if not, then we'll only sum a single column, which will be the metric that's
      # been selected

      cols_to_sum = if has_cols?
                      crosstab_col_names
                    else
                      metric_alias
                    end

      sum_cols =  Array.wrap(cols_to_sum).map { |c| from_tbl[c].sum.as(Arel.sql("\"#{c}\"")) }

      # if there is a total column, add that as well
      if has_cols?
        sum_cols.append(from_tbl[self.class::TOTAL_COL_NAME].sum.as(self.class::TOTAL_COL_NAME))
      end

      from_tbl.project(sum_cols)
    end

    def total_row_for_with
      Arel::Nodes::As.new(total_row_tbl, total_row_cte)
    end
  
end

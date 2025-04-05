module SAL::Queries::Summaries::FinalQuery
  extend ActiveSupport::Concern

  private

    def withs
      if has_rows_no_cols?
        [
          initial_query_for_with,
          total_row_for_with,
          limited_and_ordered_for_with,
          pre_calculations_for_with,
          calculations_for_with,
          aggregates_for_with,
          with_aggregates_for_with
        ]
      elsif has_cols_no_rows?
        [
          initial_query_for_with,
          total_column_for_with,
          pre_calculations_for_with,
          calculations_for_with,
          aggregates_for_with,
          with_aggregates_for_with
        ]
      elsif has_rows_and_cols?
        [
          initial_query_for_with,
          total_column_for_with,
          with_total_column_for_with,
          total_row_for_with,
          limited_and_ordered_for_with,
          pre_calculations_for_with,
          calculations_for_with,
          aggregates_for_with,
          with_aggregates_for_with
        ]
      end
    end

    def final_query
      if has_neither_rows_nor_cols?
        initial_query
      else
        sel = with_aggregates_tbl
                .project(Arel.star)
                .with(withs)
          
        # if there are rows, we should order
        o_by = ['_order_by ASC']

        if @order_by.present?
          o_by << @order_by.join(" ")
        elsif has_rows?
          addl_order_by = has_cols? ? self.class::TOTAL_COL_NAME : metric_alias
          o_by << "#{addl_order_by} DESC"
        # else if only columns, nothing to order
        end
        
        sel.order(*o_by)
      end
    end

end

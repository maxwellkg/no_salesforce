module SAL::Queries::Summaries::PreCalculations
  extend ActiveSupport::Concern

  private

    ORDER_BY_COL_NAME = '_order_by'

    PRE_CALCULATIONS_CTE_NAME = 'pre_calculations'.freeze

    def pre_calculations_tbl
      Arel::Table.new(PRE_CALCULATIONS_CTE_NAME)
    end

    def pre_calculations_cte
      if has_cols_no_rows?
        klass
          .from("iq, #{self.class::TOTAL_COLUMN_CTE_NAME}")
          .select(Arel.star)
          .arel
      else
        limited_and_ordered_tbl
          .project([Arel.star, Arel.sql("1 AS #{ORDER_BY_COL_NAME}")])
          .union(
            total_row_tbl.project([
              Arel.sql("'TOTAL'"),
              Arel.star,
              Arel.sql("2 AS #{ORDER_BY_COL_NAME}")
            ])
          )
      end
    end

    def pre_calculations_for_with
      Arel::Nodes::As.new(pre_calculations_tbl, pre_calculations_cte)
    end

end

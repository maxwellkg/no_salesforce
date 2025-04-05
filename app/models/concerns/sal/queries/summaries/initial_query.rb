module SAL::Queries::Summaries::InitialQuery
  extend ActiveSupport::Concern

  private

    # initial query: when only rows, just use the data query
    #
    # when only columns, add a static column using the metric name
    # (which will become the single row), and then create a crosstab
    #
    # when rows and columns, create a crosstab

    def initial_query
      if has_rows_no_cols?
        data_query
      elsif has_cols_no_rows?
        crosstab_query(data_query(prepend_group_bys: [self.class::TOTAL_COL_TEXT]), ct_cols)
      elsif has_rows_and_cols?
        crosstab_query(data_query, ct_cols)
      elsif has_neither_rows_nor_cols?
        data_query
      end
    end

    INITIAL_QUERY_CTE_NAME = 'iq'.freeze

    def initial_query_tbl
      Arel::Table.new(INITIAL_QUERY_CTE_NAME)
    end

    def initial_query_for_with
      Arel::Nodes::As.new(initial_query_tbl, convert_to_arel(initial_query))
    end

end

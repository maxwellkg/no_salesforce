module SAL::Queries::Summaries::Aggregates
  extend ActiveSupport::Concern

  private

    AGGREGATES_CTE_NAME = 'aggregates'.freeze

    def aggregates_tbl
      Arel::Table.new(AGGREGATES_CTE_NAME)
    end

    def num_crosstab_cols
      crosstab_col_names.length
    end

    def aggregates_cte_for_cols_no_rows
      Arel.sql(%{
        (
          SELECT
            '_AGGREGATES',
            #{Array.new(num_crosstab_cols + 1) { 'NULL::numeric' }.join(', ') },
            2 AS _order_by,
            NULL::integer AS _row_count,
            NULL::integer AS _rows_shown,
            #{num_crosstab_cols} AS _col_count,
            #{num_crosstab_cols} AS _cols_shown,
            (SELECT row_total FROM total_column) AS _total,
            (SELECT row_total FROM total_column) AS _total_shown
        )
      })
    end

    def aggregates_cte_for_rows
      if has_cols?
        col_counts_select = num_crosstab_cols
        null_fillers = num_crosstab_cols + 1
        total_selector = 'row_total'
      else
        col_counts_select = 'NULL::numeric'
        null_fillers = 1
        total_selector = metric_alias
      end

      Arel.sql(%{
        (
          SELECT
            '_AGGREGATES',
            #{Array.new(null_fillers) { 'NULL::numeric' }.join(', ')},
            3 AS _order_by,
            (SELECT COUNT(*) FROM iq) AS _row_count,
            (SELECT COUNT(*) FROM limited_and_ordered) AS _rows_shown,
            (SELECT #{col_counts_select}) AS _col_count,
            (SELECT #{col_counts_select}) AS _cols_shown,
            (SELECT #{total_selector} FROM total_row) AS _total,
            (SELECT SUM(#{total_selector}) FROM limited_and_ordered) AS _total_shown
        )
      })
    end

    def aggregates_cte
      if has_cols_no_rows?
        aggregates_cte_for_cols_no_rows
      elsif has_rows?
        aggregates_cte_for_rows
      end
    end

    def aggregates_for_with
      Arel::Nodes::As.new(aggregates_tbl, aggregates_cte)
    end

    WITH_AGGREGATES_CTE_NAME = 'with_aggregates'.freeze

    def with_aggregates_tbl
      Arel::Table.new(WITH_AGGREGATES_CTE_NAME)
    end

    def with_aggregates_cte
      if has_cols_no_rows?
        Arel.sql(%{
          (
            SELECT
              *,
              1 AS _order_by,
              NULL::integer AS _row_count,
              NULL::integer AS _rows_shown,
              NULL::integer AS _col_count,
              NULL::integer AS _cols_shown,
              NULL::numeric AS _total,
              NULL::numeric AS _total_shown
            FROM with_calculations

            UNION

            SELECT * FROM aggregates
          )
        })
      elsif has_rows?
        Arel.sql(%{
          (
            SELECT
              *,
              NULL::integer AS _row_count,
              NULL::integer AS _rows_shown,
              NULL::integer AS _col_count,
              NULL::integer AS _cols_shown,
              NULL::numeric AS _total,
              NULL::numeric AS _total_shown
            FROM with_calculations
            
            UNION

            SELECT * FROM aggregates          
          )
        })
      end
    end

    def with_aggregates_for_with
      Arel::Nodes::As.new(with_aggregates_tbl, with_aggregates_cte)
    end

end
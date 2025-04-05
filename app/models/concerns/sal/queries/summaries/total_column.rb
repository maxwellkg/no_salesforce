module SAL::Queries::Summaries::TotalColumn
  extend ActiveSupport::Concern

  private

    TOTAL_COL_NAME = 'row_total'.freeze

    TOTAL_COLUMN_CTE_NAME = 'total_column'.freeze

    def total_column_tbl
      @_total_column_tbl ||= Arel::Table.new(TOTAL_COLUMN_CTE_NAME)
    end    

    def total_column_cte
      # select the sum of all the columns put together, each coalesced first
      # with zero in case they aren't present in that particular row
      cols_to_add = crosstab_col_names.map do |cn|
        Arel::Nodes::NamedFunction.new(
          'COALESCE',
          [
            initial_query_tbl[cn],
            Arel.sql('0')
          ]
        )
      end

      sum_pj = Arel.sql("SUM(#{cols_to_add.map(&:to_sql).join(' + ')}) AS #{TOTAL_COL_NAME}")

      if has_rows?
        initial_query_tbl
          .project([Arel.sql(alias_for_dim_name(rows)), sum_pj])
          .group(1)
      else
        initial_query_tbl.project(sum_pj)
      end
    end

    def total_column_for_with
      Arel::Nodes::As.new(total_column_tbl, total_column_cte)
    end

    WITH_TOTAL_COLUMN_NAME = 'with_total_column'.freeze

    def with_total_column_tbl
      Arel::Table.new(WITH_TOTAL_COLUMN_NAME)
    end

    def with_total_column_cte
      # if rows and columns
      # combine with a join
      if has_rows_and_cols?
        row_identifier = alias_for_dim_name(rows)

        # SELECT *
        # FROM <initial_query_tbl>
        # JOIN <total_column_tbl> ON <total_column_table>.<row_identifier> = <initial_query_tbl>.<row_identifier>

        initial_query_tbl
          .project([initial_query_tbl[Arel.star], total_column_tbl[TOTAL_COL_NAME]])
          .join(total_column_tbl).on(total_column_tbl[row_identifier].eq(initial_query_tbl[row_identifier]))

      else
        # else if only columns
        # no need to join, just combine
        #
        # SELECT *
        # FROM <initial_query_tbl>, <total_column_tbl>

        Arel.sql(%{
          SELECT *
          FROM "#{INITIAL_QUERY_CTE_NAME}", "#{TOTAL_COLUMN_CTE_NAME}"
        })
      end
    end

    def with_total_column_for_with
      Arel::Nodes::As.new(with_total_column_tbl, with_total_column_cte)
    end

end

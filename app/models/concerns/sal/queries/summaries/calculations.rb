module SAL::Queries::Summaries::Calculations
  extend ActiveSupport::Concern

  private

    def transform_for_calculation(cell_val, divisor, col_name)
      Arel::Nodes::Division.new(
        Arel::Nodes::Multiplication.new(
          cell_val,
          Arel::Nodes::SqlLiteral.new('1.0')
        ),
        divisor
      ).as(col_name.to_s).to_sql
    end

    def double_quote(text)
      ActiveRecord::Base.connection.quote_table_name(text)
    end

    def calculations_arel(calc_selects, *calc_from_tables)
      klass
        .arel_table
        .grouping(Arel.sql(%{
          SELECT #{calc_selects.join(', ')}
          FROM #{calc_from_tables.map(&:name).join(', ')}
        }))
    end

    def pre_calc_row_select
      pre_calculations_tbl[alias_for_dim_name(rows)].name
    end

    def calculation_selects(selects_for_calc)
      sfc = Array.wrap(selects_for_calc)

      if has_rows?
        sfc.prepend(pre_calc_row_select)
        sfc.append(self.class::ORDER_BY_COL_NAME)
      elsif has_cols?
        sfc.prepend(self.class::TOTAL_COL_TEXT)
      end

      sfc.flatten
    end

    def selects_for_calc_with_cols(div_tbl, divide_by_col: false)
      [crosstab_col_names, :row_total].flatten.map do |col_name|
        div_col = divide_by_col ? col_name : :row_total

        transform_for_calculation(
          pre_calculations_tbl[col_name],
          div_tbl[div_col],
          double_quote(col_name)
        )
      end
    end

    def calculations_cte_for_rows_no_cols
      raise "#{@show_values_as} is not valid with only rows" unless @show_values_as == :pct_of_column_total

      sel = transform_for_calculation(
        pre_calculations_tbl[metric_alias],
        total_row_tbl[metric_alias],
        metric_alias
      )

      calculations_arel(
        calculation_selects(sel),
        pre_calculations_tbl,
        total_row_tbl
      )
    end

    def calculations_cte_for_cols_no_rows
      raise "#{@show_values_as} is not valid with only cols" unless @show_values_as == :pct_of_row_total

      sel = selects_for_calc_with_cols(total_column_tbl)

      calculations_arel(
        calculation_selects(sel),
        pre_calculations_tbl,
        total_column_tbl
      )
    end

    def calculations_cte_for_rows_and_cols_pct_of_row_total
      sel = selects_for_calc_with_cols(pre_calculations_tbl)

      calculations_arel(
        calculation_selects(sel),
        pre_calculations_tbl
      )
    end

    def calculations_cte_for_rows_and_cols_pct_of_col_total
      sel = selects_for_calc_with_cols(total_row_tbl, divide_by_col: true)

      calculations_arel(
        calculation_selects(sel),
        pre_calculations_tbl,
        total_row_tbl
      )
    end

    def calculations_cte_for_rows_and_cols_pct_of_grand_total
      sel = selects_for_calc_with_cols(total_row_tbl)

      calculations_arel(
        calculation_selects(sel),
        pre_calculations_tbl,
        total_row_tbl
      )
    end

    def calculations_cte
      # no calculation
      # => ignore and just select everything from the pre-calculation table
      # calculation
      # => only rows (as pct of column)
      # => only columns (as pct of row)
      # => rows and cols (pct of column)
      # => rows and cols (pct of row)
      # => rows and cols (pct of grand total)

      if no_calculation?
        pre_calculations_tbl.project(Arel.star)
      else
        if has_rows_no_cols?
          calculations_cte_for_rows_no_cols
        elsif has_cols_no_rows?
          calculations_cte_for_cols_no_rows
        elsif has_rows_and_cols?
          case @show_values_as
          when :pct_of_row_total
            calculations_cte_for_rows_and_cols_pct_of_row_total
          when :pct_of_column_total
            calculations_cte_for_rows_and_cols_pct_of_col_total
          when :pct_of_grand_total
            calculations_cte_for_rows_and_cols_pct_of_grand_total
          end
        end
      end
    end

    CALCULATIONS_CTE_NAME = 'with_calculations'.freeze

    def calculations_tbl
      Arel::Table.new(CALCULATIONS_CTE_NAME)
    end

    def calculations_for_with
      Arel::Nodes::As.new(calculations_tbl, calculations_cte)
    end  

    def no_calculation?
      @show_values_as == :no_calculation
    end

    def show_values_as_calculation?
      !no_calculation?
    end

end

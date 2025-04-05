class SAL::Summary
  include SAL::Queries::General,
          SAL::Queries::Summaries::RowsAndColumns,
          SAL::Queries::Reflections,
          SAL::Queries::Conditions,
          SAL::Queries::Selects,
          SAL::Queries::Summaries::DataQuery,
          SAL::Queries::Summaries::InitialQuery,
          SAL::Queries::Summaries::Crosstabs,
          SAL::Queries::Summaries::TotalColumn,
          SAL::Queries::Summaries::TotalRow,
          SAL::Queries::Summaries::LimitedAndOrdered,
          SAL::Queries::Summaries::PreCalculations,
          SAL::Queries::Summaries::Calculations,
          SAL::Queries::Summaries::Aggregates,
          SAL::Queries::Summaries::FinalQuery

  attr_reader :klass, :rows, :columns, :show_values_as

  TOTAL_COL_TEXT = "'TOTAL'".freeze

  SHOW_VALUES_AS_OPTIONS = [:no_calculation, :pct_of_row_total, :pct_of_column_total, :pct_of_grand_total]

  def initialize(klass:, metric:, conditions: {}, rows:, columns:, order_by: [], row_limit: nil, offset: nil, show_values_as: )
    @klass = klass
    @metric = metric
    @conditions = conditions
    @rows = rows
    @columns = columns
    @order_by = order_by
    @row_limit = row_limit
    @offset = offset

    # TODO: MKG 20/02/24 need to validate the options here
    @show_values_as = show_values_as
  end

  def execute!(get_totals: true)
    @_results = SAL::SummaryResult.new(self, exec_query(final_query))
    @executed = true
  end
  
  def total
    raise_if_not_executed { results.total }
  end

  def count
    raise_if_not_executed { results.count }
  end

  def results
    raise_if_not_executed { @_results }
  end

  private

    def raise_if_not_executed(&block)
      raise "Not yet executed!" unless executed?

      block.call
    end

    def executed?
      @executed
    end

    def metric_alias
      @metric[:alias]
    end

end

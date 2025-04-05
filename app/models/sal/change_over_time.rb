class SAL::ChangeOverTime
  include SAL::Queries::General,
          SAL::Queries::Reflections,
          SAL::Queries::Conditions,
          SAL::Queries::Selects


  attr_reader :klass, :metric, :date_field, 
              :period_1, :period_2,
              :rows, :order_by, :limit, :offset

  def initialize(klass:, metric:, date_field:, period_1:, period_2:, conditions: {}, rows: nil, order_by: nil, limit: nil, offset: nil)
    @klass = klass
    @metric = metric
    @date_field = date_field
    @period_1 = period_1.to_date
    @period_2 = period_2.to_date
    @conditions = conditions
    @rows = rows
    @order_by = order_by
    @limit = limit
    @offset = offset
  end

  def execute!
    set_results
    set_total_results

    @executed = true
  end

  def executed?
    @executed || false
  end

  def results
    raise_if_not_executed { @_results }
  end

  def has_rows?
    rows.present?
  end

  def row_dim
    if has_rows?
      SAL::Dimension.find_by_name(klass, rows)
    end
  end  

  private

    def raise_if_not_executed(&block)
      raise "Not yet executed!" unless executed?

      block.call
    end  

    def metric_select_filter(period)
      klass.arel_table[date_field].eq(period)
    end

    def data_query_group_by_select
      has_rows? ? group_by_select(rows) : nil
    end

    def data_query_selects
      [
        data_query_group_by_select,
        metric_select(metric_hsh: metric, filter: metric_select_filter(period_1), sql_alias: "period_1"),
        metric_select(metric_hsh: metric, filter: metric_select_filter(period_2), sql_alias: "period_2")
      ].flatten
    end

    def data_query_group
      has_rows? ? "1" : nil
    end

    def reflections_to_join
      reflections_for_dims(@conditions.keys, rows)
    end

    def joined_and_filtered_query
      klass
        .joins(reflections_to_join)
        .where(conditions)
    end

    def data_query
      joined_and_filtered_query
        .select(data_query_selects)
        .group(data_query_group)
    end

    DATA_QUERY_CTE_NAME = "data_query".freeze

    def data_query_tbl
      Arel::Table.new(DATA_QUERY_CTE_NAME) 
    end

    def data_query_for_with
      Arel::Nodes::As.new(data_query_tbl, data_query.arel)
    end

    def final_query_group_by_select
      has_rows? ? alias_for_dim_name(rows) : nil
    end

    def final_query_select_strs
      [
        final_query_group_by_select,
        "period_1",
        "period_2",
        "(period_2 - period_1) AS change",
        "(((period_2 - period_1) * 1.0) / NULLIF(period_1, 0)) AS change_pct"
      ].compact
    end

    def final_query_selects
      final_query_select_strs.map do |sel|
        Arel::Nodes::SqlLiteral.new(sel)
      end
    end

    def unlimited_query
      data_query_tbl
        .project(final_query_selects)
        .with(data_query_for_with)
    end

    def num_results_query
      data_query_tbl
        .project(Arel.star.count.as("num_results"))
        .with(data_query_for_with)
    end

    def num_results
      return nil if rows.nil?

      exec_query(num_results_query).first["num_results"]
    end

    def final_query
      sel = unlimited_query
      
      sel = sel.order(order_by) if order_by.present?
      sel = sel.take(limit) if limit.present?
      sel = sel.skip(offset) if offset.present?

      sel
    end

    def set_results
      @_results = SAL::ChangeOverTimeResult.new(self, exec_query(final_query))      
    end

    def set_total_results
      @_results.total_results = num_results
    end

end

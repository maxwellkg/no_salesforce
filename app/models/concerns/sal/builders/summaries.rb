module SAL::Builders::Summaries
  extend ActiveSupport::Concern

  included do

    alias_method :analysis, :query

    def groupable?
      true
    end

    def rows
      params[:rows]
    end

    def columns
      params[:cols]
    end

    def group_bys
      [rows, columns].compact
    end

    def num_group_bys
      group_bys.length
    end

    def build_analysis
      SAL::Summary.new(
        klass: config.klass,
        metric: metric_hsh,
        conditions: process_conditions,
        rows: rows,
        columns: columns,
        order_by: params[:order_by],
        row_limit: process_row_limit,
        offset: process_offset,
        show_values_as: show_values_as
      )
    end

    def metric
      params[:metric] || config.default_metric
    end

    def show_values_as
      params[:show_values_as].to_sym
    end

    private

      def process_rows_or_cols(rows_or_cols)
        row_or_col_val = self.send(rows_or_cols)

        if config.groupable_settings[row_or_col_val].keys.include?(:dim_name)
          config.groupable_settings[row_or_col_val].slice(:dim_name, :func, :alias)
        else
          row_or_col_val
        end
      end

      def process_rows
        process_rows_or_cols(:rows)
      end

      def process_columns
        process_rows_or_cols(:columns)
      end



      def process_offset
        return [] if group_bys.empty?

        dim = config.dimension_for_groupable(group_bys.first)

        params.delete(:offset) unless dim.date_col?
      end

      def process_row_limit
        return [] if group_bys.empty?

        dim = config.dimension_for_groupable(group_bys.first)

        params.delete(:row_limit) unless dim.date_col?
      end

  end

end

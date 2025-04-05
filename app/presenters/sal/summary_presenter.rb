class SAL::SummaryPresenter < ApplicationPresenter
    
  attr_reader :builder, :options

  delegate :mode, :config, to: :builder
  delegate_missing_to :analysis

  CHART_ITEM_DEFAULT_LIMIT = 25.freeze

  CHART_DEFAULT_SETTINGS = {
    thousands: ','
  }

  CHART_TYPES = {
    line_chart: {
      icon: 'line.png',
      validity_check: :timeseries?,
      chart_method: :line_chart
    },
    column_chart: {
      icon: 'column.png',
      validity_check: -> (analysis) { !analysis.column_timeseries? }, # always valid
      chart_method: :column_chart
    },
    stacked_column_chart: {
      icon: 'stacked_column.png',
      validity_check: -> (analysis) { analysis.double_axis? && !analysis.column_timeseries? },
      chart_method: :column_chart,
      settings: {
        stacked: true
      }
    },
    donut_chart: {
      icon: 'donut.png',
      validity_check: -> (analysis) { analysis.single_axis? && !analysis.timeseries? },
      chart_method: :pie_chart,
      settings: {
        donut: true
      }
    },
    # geo_chart: {
    #   icon: 'geo.png',
    #   validity_check: -> (analysis) { analysis.geographic? && (analysis.single_axis? || analysis.timeseries?) },
    #   type_id: 'geo',
    #   data: -> (analysis) { analysis.geo_chart_data(limit: CHART_ITEM_LIMIT) }
    # }
  }

  def initialize(builder, options = {})
    @builder = builder
    @options = options
  end

  def results_header
    if results.row_count.present?
      countable = builder.config.groupable_settings.dig(builder.group_bys.first, :display_name) || 'Results'

      rh = pluralize(number_with_delimiter(results.row_count), countable)

      if total.present?
        totalable = builder.config.settings_for_metric(builder.metric).dig(:result_options, :totalable)
        verb = builder.config.settings_for_metric(builder.metric).dig(:result_options, :summary_verb) || 'Totaling'

        transf = builder.config.settings_for_metric(builder.metric).dig(:result_options, :display_transformation)
        transf_total = transf.present? ? transf.to_proc.call(total) : total

        total = totalable.present? ? pluralize(number_with_delimiter(transf_total), totalable) : value_display(transf_total)
        
        rh = "#{rh} #{verb} #{total}"
      end

      rh
    else
      'Results'
    end
  end

  def no_matching_results?
    results.empty?
  end

  def analysis
    @builder.analysis
  end

  def show_charts_for_single_axis?
    if has_rows_no_cols?
      results.row_count <= CHART_ITEM_DEFAULT_LIMIT
    elsif has_cols_no_rows?
      results.col_count <= CHART_ITEM_DEFAULT_LIMIT
    end
  end

  def show_charts_for_double_axis?
    results.row_count <= CHART_ITEM_DEFAULT_LIMIT && results.col_count <= CHART_ITEM_DEFAULT_LIMIT
  end

  def show_charts?
=begin
    if @options.has_key?(:show_charts)
      @options[:show_charts]
    elsif has_neither_rows_nor_cols?
      false
    else
      true
    end
=end
    if column_timeseries?
      true
    else
      show_values_as == :no_calculation &&
        ((single_axis? && show_charts_for_single_axis?) ||
          (double_axis? && show_charts_for_double_axis?))
    end
  end

  def klass
    builder.config.klass
  end

  def row_timeseries?
    row_dim&.date_col? || false
  end

  def column_timeseries?
    col_dim&.date_col? || false
  end

  def timeseries?
    row_timeseries? || column_timeseries?
  end

  def metric_display
    builder.config.settings_for_metric(builder.metric)[:display_name]
  end

  def rows_display_name
    builder.config.groupable_settings[rows][:display_name]
  end

  def columns_display_name
    builder.config.groupable_settings[columns][:display_name]
  end

  def column_headers(for_csv: false)
    headers = if analysis.has_cols?
                display_transf = builder.config.groupable_settings.dig(analysis.columns, :result_options, :display_transformation)
                csv_transf = builder.config.groupable_settings.dig(analysis.columns, :result_options, :csv_transformation)

                # if for csv, use the csv transformation, falling back on the display transformation if it is provided and a
                # csv transformation is not
                # otherwise, look for the display transformation

                transf = for_csv ? (csv_transf || display_transf) : display_transf

                if transf.present?
                  analysis.results.objectified_columns.dup.map do |col|
                    begin
                      instance_exec(col, &transf)
                    rescue
                      col
                    end
                  end
                else
                  analysis.results.objectified_columns
                end
              else
                analysis.results.objectified_columns
              end

    if has_rows?
      headers[0] = builder.config.groupable_settings.dig(analysis.rows, :display_name)
    end

    if has_rows_no_cols?
      headers[1] = builder.config.metric_settings.dig(builder.metric, :display_name)
    end

    if has_neither_rows_nor_cols?
      headers[0] = builder.config.metric_settings.dig(builder.metric, :display_name)
    end

    headers
  end

  def groupable_header_name(dim_name, object, for_csv: false)
    # if the csv transformation is not specified but we are creating a csv, fall back on the display transformation
    transf_key =  if for_csv
                    if builder.config.groupable_settings.dig(dim_name, :result_options).has_key?(:csv_transformation)
                      :csv_transformation
                    else
                      :display_transformation
                    end
                  else
                    :display_transformation
                  end

    transformation = builder.config.groupable_settings.dig(dim_name, :result_options, transf_key)

    transformation.nil? ? object : transformation.to_proc.call(object)
  end

  def row_header_display(row_header, for_csv: false)
    if row_header == 'TOTAL'
      row_header
    elsif row_header.blank?
      'Unavailable'
    else
      groupable_header_name(builder.group_bys.first, row_header, for_csv: for_csv)
    end
  end

=begin
  def rows(for_csv: false)
    if has_neither_rows_nor_cols?
      [[analysis.results.first.second]]
    elsif has_rows_and_cols?
      groupby2_values = analysis.results_keyed_by_objects.values.map(&:keys).flatten.uniq.sort

      results_keyed_by_objects
        .transform_keys { |k| row_header_display(k, for_csv: for_csv) }
        .transform_values { |v| v.values_at(*groupby2_values) }
        .to_a
        .map(&:flatten)
    elsif has_rows?
      results_keyed_by_objects
        .transform_keys { |k| row_header_display(k) }
        .transform_values { |v| v.values.first }
        .to_a
    elsif has_cols?
      groupby1_values = analysis.results_keyed_by_objects.keys
      groupby1_values.sort! if column_timeseries?

      [[metric_display, results_keyed_by_objects.values_at(*groupby1_values).map { |v| v.values.first }].flatten]
    end
  end
=end

  def to_array(with_headers: true)
    arr = results.rows

    arr.prepend(headers) if with_headers

    arr
  end

  def single_axis?
    (has_rows? && !has_cols?) || (has_cols? && !has_rows?)
  end

  def double_axis?
    has_rows? && has_cols?
  end

  def geographic_model?(model)
    model.respond_to?(:geographic?) && model.geographic?
  end

  def row_geographic?
    geographic_model?(row_dim.klass)
  end

  def column_geographic?
    return false unless column_dim.present?

    geographic_model?(column_dim.klass)
  end

  def geographic?
    row_geographic? || column_geographic?
  end

  def config_disallows_chart_type?(chart_type)
    shortened_chart_type = chart_type.to_s.gsub('_chart', '').to_sym
    builder.config.settings_for_metric(builder.metric).dig(:result_options, :charts, :exclude)&.include?(shortened_chart_type) || false
  end

  def valid_chart_types
    CHART_TYPES.select do |type, type_settings|
      type_settings[:validity_check].to_proc.call(self) &&
        !config_disallows_chart_type?(type)
    end
  end

  def default_chart_type
    if timeseries?
      :line_chart
    # elsif geographic? && single_axis?
    #   :geo
    elsif double_axis?
      :stacked_column_chart
    else
      :donut_chart
    end
  end

  def apply_transformation(transformation, value)
    value.nil? ? 'Unknown' : transformation.to_proc.call(value)
  end

  def show_all_other_in_chart?
    show_all_other = builder.config.settings_for_metric(builder.metric).dig(:result_options, :charts, :show_all_other)

    show_all_other.nil? ? false : show_all_other
  end

  def single_axis_chart_data(limit:)
    raise "Should only be used with a single axis!" unless single_axis?

    @_chart_data ||= begin
      metric_alias = builder.config.metric_alias(builder.metric)

      grouped = builder.rows || builder.columns

      chart_data =  if has_rows_no_cols?
                      results.objectified_rows_excluding_total.each_with_object({}) do |row, hsh|
                        hsh[row.first] = row.second
                      end
                    elsif has_cols_no_rows?
                      # ignore first col (row header) and row total
                      results.objectified_columns.each_with_object({}).with_index do |(col, hsh), index|
                        unless [0, results.objectified_columns.length - 1].include?(index)
                          hsh[col] = results.objectified_rows.first[index]
                        end
                      end
                    else
                      raise "single axis shouldn't be  used!"
                    end

      # transform the rows/columns to the display version
      # ignore for timeseries as we'll want to leave in date format
      transf = @builder.config.groupable_settings.dig(grouped, :result_options, :display_transformation)

      if transf.present? && !timeseries?
        chart_data.transform_keys! { |k| apply_transformation(transf, k) }
      end

      # limit to the top n largest results
      # ignore the limit in the case of timeseries data
      if limit.present? && chart_data.length > limit && !timeseries?
        chart_data = chart_data.sort_by { |k, v| v }.reverse[0..limit-1].to_h

        if show_all_other_in_chart?
          chart_data['All Other'] = results.total - chart_data.values.compact.sum
        end
      end

      # resort by date if timeseries as Highcharts won't handle rearranging and you get a very strange
      # looking graph
      #
      # otherwise keep sorted by value
      chart_data = chart_data.sort_by { |k, _v| k }.to_h if timeseries?

      chart_data
    end
  end

  def double_axis_chart_data(chart_type:, row_limit:, col_limit:)
    raise "Should only be used with a double axis!" unless double_axis?

    @_chart_data ||= begin
      row_transformation = builder.config.groupable_settings.dig(builder.rows, :result_options, :display_transformation)
      col_transformation = builder.config.groupable_settings.dig(builder.columns, :result_options, :display_transformation)

      # only for timeseries
      if chart_type == :line_chart
        chart_data =  begin
                        if row_timeseries?
                          results.objectified_columns.map.with_index do |col, idx|
                            unless [0, results.objectified_columns.length - 1].include?(idx)
                              series_name = col_transformation.present? ? apply_transformation(col_transformation, col) : col

                              series_data = results.objectified_rows_excluding_total.each_with_object({}) do |row, hsh|
                                hsh[row.first] = row[idx]
                              end

                              { name: series_name, data: series_data }
                            end
                          end.compact
                        elsif column_timeseries?
                          results.objectified_rows_excluding_total.map do |row|
                            series_for = row.first

                            series_name = row_transformation.present? ? apply_transformation(row_transformation, series_for) : series_for

                            series_data = results.objectified_columns.each_with_object({}).with_index do |(col, hsh), idx|
                              unless [0, results.objectified_columns.length - 1].include?(idx)
                                hsh[col] = row[idx]
                              end
                            end.compact

                            { name: series_name, data: series_data }
                          end
                        end
                      end

        dates = if row_timeseries?
                  results.objectified_rows_excluding_total.map(&:first)
                else
                  results.objectified_columns[1..-2]
                end

        max_date = dates.max

        chart_data = chart_data.sort_by { |series| series[:data][max_date] || 0 }.reverse
        chart_data.each { |series| series[:data] = series[:data].sort_by { |date, value| date.to_date }.to_h }

        if row_limit.present?
          chart_data = chart_data.sort_by do |series|
            series[:data].values.compact.sum
          end.reverse[0..row_limit-1]
        end
      else
        chart_data = results.objectified_rows_excluding_total[..row_limit-1].map do |row|
          series_for = row.first

          series_name = row_transformation.present? ? apply_transformation(row_transformation, series_for) : series_for

          series_total = row.last

          # create a hash tracking index + value


          # sort by value

          # get the top n indexes

          # add top n indexes to series data

          index_hsh = row.each_with_object({}).with_index do |(c, hsh), idx|
            unless [0, row.length-1].include?(idx)
              hsh[idx] = c
            end
          end

          top_n_indexes = index_hsh.sort_by { |_, v| v || 0 }.reverse[..row_limit-1].map(&:first)

          series_data = top_n_indexes.each_with_object({}) do |idx, hsh|
            col = results.objectified_columns[idx]

            key = col_transformation.present? ? apply_transformation(col_transformation, col) : col

            hsh[key] = row[idx]
          end

          { name: series_name, data: series_data }
        end

      end

      chart_data
    end
  end

  def chart_item_limit
    options.has_key?(:chart_item_limit) ? options[:chart_item_limit] : CHART_ITEM_DEFAULT_LIMIT
  end

  def chart_data(chart_type, limit: nil)
    if double_axis?
      double_axis_chart_data(chart_type: chart_type, row_limit: limit, col_limit: limit)
    else
      single_axis_chart_data(limit: limit)
    end
  end

  def chart(chart_type, limit: chart_item_limit)
    type_settings = CHART_TYPES.dig(chart_type, :settings) || {}
    metric_settings = builder.config.settings_for_metric(builder.metric).dig(:result_options, :chart_settings) || {}
    type_settings.merge!(metric_settings)


    {
      method: CHART_TYPES.dig(chart_type, :chart_method),
      chart_data: chart_data(chart_type, limit: limit),
      settings: CHART_DEFAULT_SETTINGS.merge(type_settings)
    }
  end

  def chart_without_limit(chart_type)
    chart(chart_type, limit: nil)
  end

  def table_data(for_csv: false)
    @_table_data ||= begin
      results.objectified_rows.map(&:dup).map do |r|
        if has_rows?
          r[0]  =  begin
                    row_header_display(r.first, for_csv: for_csv)
                  rescue
                    r.first
                  end
        end

        r
      end
    end
  end

  private

    def group_bys
      analysis.instance_variable_get('@group_by')
    end

end

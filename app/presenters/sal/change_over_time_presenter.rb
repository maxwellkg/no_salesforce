class SAL::ChangeOverTimePresenter < ApplicationPresenter

  attr_reader :builder
  delegate :query, to: :builder
  delegate :results, to: :query

  # TODO 02/03/25 MKG
  # clean this up in the pagination helper
  delegate :has_rows?, to: :query

  def initialize(builder)
    @builder = builder
  end

  def results_header
    change_in = builder.config.countable.titleize.pluralize
    grouped_by = builder.config.groupable_settings.dig(builder.rows, :display_name)

    "Change in #{change_in} #{"by #{grouped_by} " if builder.query.has_rows?}from #{builder.period_1} through #{builder.period_2}"
  end

  def show_charts?
    false
  end

  def no_matching_results?
    results.total_results == 0
  end
  
  def rows_col_header
    if query.has_rows?
      row_settings[:display_name] || ""
    end
  end

  def display_headers
    [
      rows_col_header,
      query.period_1,
      query.period_2,
      "Change",
      "Change Percent"
    ].compact
  end

  def grouped?
    query.has_rows?
  end

  def display_rows(for_csv: false)
    transf_key = for_csv ? :csv_transformation : :display_transformation

    @_display_rows ||= begin
      results.objectified_rows.map do |row|
        new_r = []

        if grouped?
          transf = row_settings.dig(:result_options, transf_key)

          if transf.present?
            new_r << transf.to_proc.call(row[0])
          end
        end

        new_r << number_with_delimiter(row[-4])
        new_r << number_with_delimiter(row[-3])
        new_r << number_with_delimiter(row[-2])
        new_r << number_to_percentage((row[-1]&. * 100), precision: 2)

        new_r
      end
    end
  end

  def rows_display_name
    row_settings[:display_name]
  end  

  private

    def row_settings
      builder.config.groupable_settings[query.rows]
    end

end

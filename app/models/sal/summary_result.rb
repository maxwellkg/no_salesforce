class SAL::SummaryResult

  attr_reader :analysis, :ar_result

  delegate_missing_to :ar_result

  def initialize(analysis, ar_result)
    @analysis = analysis
    @ar_result = ar_result
  end

  # for both rows and columns, replace the string version of the result
  # with an object, where applicable
  #
  # where the dimension is a reflection, the string should be replaced with objects
  # (the string will be the identifier for that record)
  #
  # where the dimension is a date, the string should be replaced with a date object

  def objectified_columns
    @_objectified_columns ||= begin
      if analysis.has_neither_rows_nor_cols?
        ar_result.columns.dup
      else
        if analysis.has_cols?
          if analysis.col_dim.reflection?
            objectified_columns_for_reflection
          elsif analysis.col_dim.date_col?
            columns.map { |c| attempt_date_conversion(c) }
          else
            ar_result.columns
          end
        else
          ar_result.columns
        end[..-8]
      end
    end
  end

  def objectified_rows
    @_objectified_rows ||=  begin
      if analysis.has_neither_rows_nor_cols?
        ar_result.rows
      else
        if analysis.has_rows?
          if analysis.row_dim.reflection?
            objectified_rows_for_reflection
          elsif analysis.row_dim.date_col?
            change_first_in_row(-> (date_val) { date_val == 'TOTAL' ? date_val : date_val.to_date })
          else
            rows_except_aggregates
          end
        else
          rows_except_aggregates
        end.map do |r|
          r[..-8]
        end
      end
    end
  end

  def objectified_rows_excluding_total
    objectified_rows.reject { |r| r.first == 'TOTAL' }
  end

  def total
    analysis.has_neither_rows_nor_cols? ? rows.first[0] : get_aggregate('_total')
  end

  def total_shown
    analysis.has_neither_rows_nor_cols? ? rows.first[0] : get_aggregate('_total_shown')
  end

  def row_count
    return nil if analysis.has_neither_rows_nor_cols?

    get_aggregate('_row_count')
  end

  def rows_shown
    return nil if analysis.has_neither_rows_nor_cols?

    get_aggregate('_rows_shown')
  end

  def col_count
    return nil if analysis.has_neither_rows_nor_cols?

    get_aggregate('_col_count')
  end

  def cols_shown
    return nil if analysis.has_neither_rows_nor_cols?

    get_aggregate('_cols_shown')
  end

  private

    def aggregates
      last
    end

    def get_aggregate(key)
      aggregates&.fetch(key)
    end

    def rows_except_aggregates
      rows[..-2]
    end

    def rows_except_aggregates_and_total
      rows[..-3]
    end

    def aggregates_row
      last
    end

    def get_objects_for_dimension(dimension, ids)
      dimension.reflection.klass.find(ids)
    end

    def match_to_key(key, collection, attribute_to_match, return_key_if_missing: false)
      mtch = collection.detect { |i| attribute_to_match.to_proc.call(i) == key }

      mtch.blank? && return_key_if_missing ? key : mtch
    end

    # even in date columns, not all the returned values may be dates
    # for example we use the string 'TOTAL' in the totals row
    #
    # when the value is not a date, return it as-is rather than raising an error

    def attempt_date_conversion(str)
      str.to_date rescue str.titleize
    end

    def objectified_columns_for_reflection
      # strip out the header (first position) and the totals/aggregates (last 8 positions)
      ids = columns[1..-9]

      objects = get_objects_for_dimension(analysis.col_dim, ids)

      columns.map do |c|
        match_to_key(c, objects, -> (obj) { obj.id.to_s }, return_key_if_missing: true)
      end
    end

    def change_first_in_row(update_proc)
      rows_except_aggregates.map do |r|
        # duplicate as we don't want to override the original
        new_r = r.dup

        new_r[0] = update_proc.call(r.first)

        new_r
      end
    end

    def objectified_rows_for_reflection
      ids = rows_except_aggregates_and_total.map(&:first)

      objects = get_objects_for_dimension(analysis.row_dim, ids)

      change_first_in_row(-> (r) { match_to_key(r, objects, -> (obj) { obj.id.to_s }, return_key_if_missing: true) })
    end

end

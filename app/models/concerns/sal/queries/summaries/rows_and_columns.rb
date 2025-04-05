module SAL::Queries::Summaries::RowsAndColumns
  extend ActiveSupport::Concern

  def has_rows?
    rows.present?
  end

  def row_dim
    if has_rows?
      SAL::Dimension.find_by_name(klass, rows)
    end
  end

  def has_cols?
    columns.present?
  end

  def col_dim
    if has_cols?
      SAL::Dimension.find_by_name(klass, columns)
    end
  end

  def has_rows_no_cols?
    has_rows? && !has_cols?
  end

  def has_cols_no_rows?
    has_cols? && !has_rows?
  end

  def has_rows_and_cols?
    has_rows? && has_cols?
  end

  def has_neither_rows_nor_cols?
    !has_rows? && !has_cols?
  end

end

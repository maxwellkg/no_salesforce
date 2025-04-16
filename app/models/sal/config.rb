class SAL::Config
  include Singleton

  SEARCHABLES = []
  FILTERABLES = []

  # the default title is the pluralized name of the class,
  # but this can/should be overwritten

  def title
    klass.to_s.demodulize.pluralize
  end

  def searchables
    self.class::SEARCHABLES
  end

  def filterables
    self.class::FILTERABLES
  end

  def searchable_methods
    searchables.map { |s| s[:search_method] }
  end

  def searchable_method?(method_name)
    searchable_methods.include?(method_name.to_sym)
  end

  def settings_for_searchable(search_method)
    searchables.detect { |s| s[:search_method] == search_method.to_sym }
  end

  def filterable_fields
    filterables.map { |f| f[:field] }
  end

  def filterable_field?(field_name)
    filterable_fields.include?(field_name.to_sym)
  end

  def settings_for_filterable(field_name)
    filterables.detect { |f| f[:field] == field_name.to_sym }
  end

  def date_filter?(field_name)
    col = klass.columns.detect { |col| col.name == field_name.to_s }

    [:date, :datetime].include?(col.type)
  end

  def filter_allows_multiple?(field_name)
    return false unless filterable_field?(field_name)

    settings_for_filterable(field_name).dig(:options, :allow_multiple)
  end

  def klass_for_filter(field_name)
    settings_for_filterable(field_name)[:klass] || klass
  end

  def include_for_advanced_search
    nil
  end

end

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

  def filterable_is_reflection?(field_name)
    settings_for_filterable(field_name)[:reflection].present?
  end

  def reflection_for_filterable(field_name)
    settings_for_filterable(field_name)[:reflection]
  end

  def column_for_field_name(field_name)
    if filterable_is_reflection?(field_name)
      ref = reflection_for_filterable(field_name)

      model = klass.reflections[ref.to_s].klass
      col_name = field_name.to_s.split('.').last
    else
      model = klass
      col_name = field_name.to_s
    end



    model.columns.detect { |c| c.name == col_name }
  end

  def date_filter?(field_name)
    column_for_field_name(field_name).type.in? [:date, :datetime]
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

  def show_new_resource_button?
    true
  end

  def countable
    klass.to_s.demodulize.downcase.pluralize
  end

end

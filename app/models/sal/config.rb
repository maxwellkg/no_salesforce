class SAL::Config
  include Singleton

  def searchable_fields
    self.class::SEARCHABLE_FIELDS
  end

  def filterable_fields
    self.class::FILTERABLE_FIELDS
  end

##############################################

  # Note, the following methods should be defined at the subclass
  # level: #klass, #default_metric, #allowable_modes, #countable

  def self.name
    self.to_s.underscore.gsub("sal/configs/", "")
  end

  delegate :name, to: :class

  def title
    klass.to_s.demodulize.pluralize
  end

  def settings
    self.class::SETTINGS
  end

  def downloadable?
    false
  end

  CONDITION_ALTERATIONS = {}.freeze

  def condition_alterations
    self.class::CONDITION_ALTERATIONS
  end

  def metric_settings
    settings[:metrics]
  end

  def settings_for_metric(metric_name)
    metric_settings[metric_name]
  end

  def metric_alias(metric_name)
    settings_for_metric(metric_name).dig(:metric_hsh, :alias)
  end

  def displayable_settings
    settings[:displayable] || {}
  end

  def default_display_attributes
    displayable_settings.select { |k, v| v[:show_by_default] }.keys
  end

  def searchable_settings
    settings[:searchable] || {}
  end

  def searchable_dimension?(dim_name)
    searchable_settings.keys.include?(dim_name)
  end

  def searchable_settings_by_field
    searchable_settings.transform_keys do |k|
      SAL::Field.find_by_name(klass, k)
    end
  end

  def settings_for_searchable_field(field_name)
    searchable_settings[field_name]
  end

  def filterable_settings
    settings[:filterable]
  end

  def filterable_settings_by_field
    filterable_settings.transform_keys do |k|
      SAL::Field.find_by_name(klass, k)
    end
  end

  def settings_for_filterable_field(field_name)
    filterable_settings[field_name]
  end

  def specified_operator_for_filterable_field(field_name)
    settings_for_filterable_field(field_name)[:operator]
  end

  def options_for_filterable_field(field_name)
    settings_for_filterable_field(field_name)[:options] || {}
  end

  def filterable_settings
    settings[:filterable] || {}
  end

  def groupable_settings
    settings[:groupable]
  end

  def dimension_for_groupable(groupable_name)
    dim_name = groupable_settings.dig(groupable_name, :dim_name) || groupable_name

    SAL::Dimension.find_by_name(klass, dim_name)
  end

  def dimension_for_filterable_or_searchable(name)
    dim_name = searchable_and_filterable_settings.dig(name, :dim_name) || name

    SAL::Dimension.find_by_name(klass, dim_name)
  end

  def searchable_and_filterable_settings
    searchable_settings.merge(filterable_settings)
  end

  def searchable_field?(field_name)
    searchable_settings.keys.include?(field_name)
  end

  def filterable_field?(field_name)
    filterable_settings.keys.include?(field_name)
  end

  def searchable_or_filterable_field?(field_name)
    searchable_field?(field_name) || filterable_field?(field_name)
  end

  def filterable_requires_operator?(field_name)
    filterable_settings.dig(field_name, :options, :user_inputs_operator) || false
  end

  def groupable_settings
    settings[:groupable] || {}
  end

  def groupable_field?(field_name)
    groupable_settings.keys.include?(field_name)
  end

end

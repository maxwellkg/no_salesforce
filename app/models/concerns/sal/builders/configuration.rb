module SAL::Builders::Configuration
  extend ActiveSupport::Concern

  included do
    delegate :klass, :searchables, :filterables, :searchable_methods, :filterable_fields, to: :class
    delegate :searchable_method?, :filterable_field?, :date_filter?, to: :class

    # the default title is the pluralized name of the class,
    # but this can/should be overwritten

    def title
      klass.to_s.demodulize.pluralize
    end    
  end

  class_methods do

    def searchables
      self::SEARCHABLES
    end

    def filterables
      self::FILTERABLES
    end

    def searchable_methods
      searchables.map { |s| s[:search_method] }
    end

    def searchable_method?(method_name)
      searchable_methods.include?(method_name)
    end

    def settings_for_searchable(search_method)
      searchables.detect { |s| s[:search_method] == search_method }
    end

    def filterable_fields
      filterables.map { |f| f[:field] }
    end

    def filterable_field?(field_name)
      filterable_fields.include?(field_name)
    end

    def settings_for_filterable(field_name)
      filterables.detect { |f| f[:field] == field_name }
    end

    def date_filter?(field_name)
      col = klass.columns.detect { |col| col.name == field_name.to_s }

      [:date, :datetime].include?(field_name)
    end

    def filter_allows_multiple?(field_name)
      return false unless filterable_field?(field_name)

      settings_for_filterable(field_name).dig(:options, :allow_multiple)
    end

  end

end

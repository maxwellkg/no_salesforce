module SAL::FieldSetter
  extend ActiveSupport::Concern

  class_methods do

    include ActionView::Helpers::UrlHelper

    def analytics_enabled?
      true
    end

    def sal_fieldset
      SAL::FieldSet.new(self)
    end

    def geograhic?
      false
    end

    def date_trunc(datepart)
      -> (col) { Arel::Nodes::NamedFunction.new('DATE_TRUNC', [Arel::Nodes::SqlLiteral.new("'#{datepart}'"), col]) }
    end

    attr_accessor :has_metrics

    def has_metrics?
      has_metrics || false
    end

    attr_accessor :targetable

    def targetable?
      targetable || false
    end

  end

end

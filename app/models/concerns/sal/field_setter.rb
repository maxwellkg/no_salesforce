module SAL::FieldSetter
  extend ActiveSupport::Concern

  class_methods do

    def sal_fieldset
      SAL::FieldSet.new(self)
    end

    def has_metrics?
      false
    end

  end

end

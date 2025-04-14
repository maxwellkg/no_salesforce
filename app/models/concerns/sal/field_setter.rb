module SAL::FieldSetter
  extend ActiveSupport::Concern

  class_methods do

    def sal_fieldset
      SAL::FieldSet.new(self)
    end

  end

end

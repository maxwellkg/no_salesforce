module SAL::Queries::Conditions
  extend ActiveSupport::Concern

  private

    def conditions
      @conditions.each_with_object({}) do |(k, v), hsh|
        dim = SAL::Dimension.find_by_name(klass, k)

        if dim.reflection?
          # conditions on associations should be given as:
          # { association_name => { associated_model_attribute_name => value } }
          hsh[dim.reflection.name] ||= {}

          hsh[dim.reflection.name][dim.column_name] = value_for_query
        else
          # conditions on the base object should be given as:
          # { attribute_name => value }
          hsh[k] = v
        end
      end
    end

end

module SAL::Queries::Conditions
  extend ActiveSupport::Concern

  private

    # in the case that there are condition values that will ALWAYS be altered by
    # business logic for ANY analysis of this type, handle them here
    #
    # e.g. for many of the UK trade data assets, when searching by a 2-digit commodity,
    # we really apply the search using all of the 8-digit commodities that fall under the 2-digit code
    #
    # TODO 02/04/24 MKG
    # move this to the builder and/or config instead???

    CONDITION_ALTERATIONS = {}.freeze

    def alter_value_for_query(dimension, value)
      if self::class::CONDITION_ALTERATIONS.has_key?(dimension.name)
        alteration = self::class::CONDITION_ALTERATIONS[dimension.name]
        alteration.call(value)
      else
        value
      end
    end    

    def conditions
      @conditions.each_with_object({}) do |(k, v), hsh|
        dim = SAL::Dimension.find_by_name(klass, k)

        value_for_query = alter_value_for_query(dim, v)

        if dim.reflection?
          # conditions on associations should be given as:
          # { association_name => { associated_model_attribute_name => value } }
          hsh[dim.reflection.name] ||= {}

          hsh[dim.reflection.name][dim.column_name] = value_for_query
        else
          # conditions on the base object should be given as:
          # { attribute_name => value }
          hsh[k] = value_for_query
        end
      end
    end

end

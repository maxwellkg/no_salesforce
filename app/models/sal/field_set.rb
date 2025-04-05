class SAL::FieldSet
  attr_reader :klass

  def initialize(klass)
    @klass = klass
  end

  def dimensions
    @_dimensions ||= get_dimensions
  end

  def reflected_dimensions
    @_reflected_dimensions ||= get_reflected_dimensions
  end

  def measures
    @_measures ||= get_measures
  end

  # for now, include reflected dimensions but not any reflected measures
  def fields
    dimensions_including_reflected + measures
  end

  def dimensions_including_reflected
    [dimensions, reflected_dimensions].flatten
  end

  private

    def model_has_measures?(model)
      (defined?(model::MEASURES) || false) && model::MEASURES.any?
    end

    def has_measures?
      model_has_measures?(klass)
    end

    def get_measures
      measure_columns.map { |col| SAL::Measure.new(klass, col) }
    end

    def measure_columns_for_model(model)
      if model_has_measures?(model)
        model::MEASURES.map do |measure_name|
          model.columns.detect { |col| col.name == measure_name.to_s }
        end.compact
      else
        []
      end
    end

    def measure_columns
      measure_columns_for_model(klass)
    end

    def cols_for_dimensions_for_model(model)
      if model_has_measures?(model)
        model.columns - measure_columns_for_model(model)
      else
        model.columns
      end
    end

    def get_dimensions
      cols_for_dimensions_for_model(klass).map do |col|
        SAL::Dimension.new(klass, col)
      end
    end


    def get_reflected_dimensions
      klass.reflect_on_all_associations.map do |ref|
        cols_for_dimensions_for_model(ref.klass).map do |col|
          unless ref.klass == klass
            SAL::Dimension.new(
              klass,
              col,
              type: :reflection,
              opts: { reflection: ref }
            )
          end
        end
      end.flatten.compact
    end
end

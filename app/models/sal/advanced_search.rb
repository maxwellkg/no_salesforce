class SAL::AdvancedSearch
  include SAL::Queries::Reflections, SAL::Queries::Conditions

  attr_reader :klass, :display_attributes

  def initialize(klass:, display_attributes:, conditions: {}, order_by: nil, limit: nil, offset: nil, force_includes: [])
    @klass = klass
    @display_attributes = display_attributes
    @conditions = conditions
    @order_by = order_by
    @limit = limit
    @offset = offset

    @force_includes = force_includes
  end

  def query
    joined_and_filtered_query
      .order(@order_by)
      .limit(@limit)
      .offset(@offset)
  end

  def results_query
    query.includes([reflections_to_include, @force_includes].flatten)
  end  

  def execute!
    @_results = results_query
    @executed = true
  end

  def results
    raise_if_not_executed { @_results }
  end

  def total_results
    @_total_results ||= joined_and_filtered_query.count
  end

  def results_shown
    @_results_shown ||= results.size
  end 

  private

    def executed?
      @executed
    end

    def raise_if_not_executed(&block)
      raise "Not yet executed!" unless executed?

      block.call
    end

    def reflections_to_include
      # TODO 05/04/24 MKG
      # figure out how to handle this as we won't necessarily want to always
      # include :metric_set
      refs = [reflections_for_dims(display_attributes)]

      refs << :metric_set if klass.has_metrics?

      refs.flatten
    end

    def reflections_to_join
      # TODO 05/04/24 MKG
      # figure out how to handle this as we won't necessarily want to always
      # join :metric_set
      refs = [reflections_for_dims([@conditions.keys, display_attributes].flatten)]

      refs << :metric_set if klass.has_metrics?

      refs.flatten
    end

    def joined_and_filtered_query
      klass
        .left_outer_joins(reflections_to_join)
        .distinct # make sure to only return one row per entity
        .where(conditions)
    end

end

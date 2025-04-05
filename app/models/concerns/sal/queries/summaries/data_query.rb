module SAL::Queries::Summaries::DataQuery
  extend ActiveSupport::Concern

  private

    def group_by_selects(prepend_group_bys: [], append_group_bys: [])
      [prepend_group_bys, rows, columns, append_group_bys].flatten.compact.map do |gb|
        group_by_select(gb)
      end    
    end

    def selects(metric_hsh:, prepend_group_bys: [], append_group_bys: [])
      [
        group_by_selects(prepend_group_bys: prepend_group_bys, append_group_bys: append_group_bys),
        metric_select(metric_hsh: metric_hsh)
      ].flatten
    end

    def group_bys(prepend_group_bys: [], append_group_bys: [])
      [prepend_group_bys, rows, columns, append_group_bys]
        .flatten
        .compact
        .each_index
        .map { |i| i + 1 }
    end

    alias_method :order_bys, :group_bys

    def reflections_to_join
      # we need to join any of the following:
      #   - metric cols that are reflections
      #   - condition cols that are reflections
      #   - group by cols that are reflections

      reflections_for_dims(@conditions.keys, rows, columns)
    end       

    # joins any required joins and applies the filters
    # this will be generally be done for all subsequent queries that may be built
    # e.g. the default data query, advanced calculations, etc.

    def joined_and_filtered_query
      klass
        .joins(reflections_to_join)
        .where(conditions)
    end    

    # data query: the query that actually gets the data for the results
    # allow for default metrics and group bys to be overriden in the case that
    # we need to perform advanced calculations

    def data_query(metric_hsh: @metric, prepend_group_bys: [], append_group_bys: [])
      query_select =  selects(
                        metric_hsh: metric_hsh,
                        prepend_group_bys: prepend_group_bys,
                        append_group_bys: append_group_bys
                      )

      # cast enums as strings so as to be able to include the total row
      if has_rows?
        sel = query_select[0].left
        al = query_select[0].right

        query_select[0] = Arel::Nodes::NamedFunction.new(
                            'CAST',
                            [sel.as('TEXT')]
                          ).as(al)
      end

      joined_and_filtered_query
        .select(
          query_select
        )
        .group(
          group_bys(
            prepend_group_bys: prepend_group_bys,
            append_group_bys: append_group_bys
          )
        )
        .order(
          order_bys(
            prepend_group_bys: prepend_group_bys,
            append_group_bys: append_group_bys
          )
        )
    end
  
end

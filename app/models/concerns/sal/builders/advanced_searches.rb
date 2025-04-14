module SAL::Builders::AdvancedSearches
  extend ActiveSupport::Concern

  included do

    def display_attributes
      params[:display_attributes] || config.default_display_attributes
    end    

    def build_advanced_search
      SAL::AdvancedSearch.new(
        klass: config.klass,
        display_attributes: display_attributes,
        conditions: process_conditions,
        order_by: process_order,
        limit: params[:row_limit],
        offset: params[:offset],
        force_includes: force_includes
      )      
    end

    private

      def force_includes
        config.settings[:display_force_includes]
      end

      def process_order
        if params[:order]
          dim = SAL::Field.find_by_name(config.klass, params[:order].first)

          tbl = if dim.reflection?
                  dim.klass.arel_table
                else
                  dim.model.arel_table
                end

          tbl[dim.column_name].send(params[:order].second).nulls_last
        end
      end      

  end

end

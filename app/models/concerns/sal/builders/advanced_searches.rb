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

  end

end

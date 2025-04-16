module SAL::AdvancedSearchable
  extend ActiveSupport::Concern

  included do

    helper_method :eager?, :fetching?, :eager_or_fetching?

    def index
      set_builder
      set_title

      render "advanced_searches/index"
    end

    private

      def set_title
        @title = @builder.title
      end

      def searchable_params
        sal_config.searchable_methods
      end

      def filterable_params
        sal_config.filterable_fields.map do |field|
          if sal_config.filter_allows_multiple?(field) || sal_config.date_filter?(field)
            { field => [] }
          else
            field
          end
        end
      end

      def allowable_params
        [searchable_params, filterable_params].flatten
      end

      def builder_params
        params.permit(allowable_params)
      end

      def sal_config
        sal_config_klass.instance
      end

      def set_builder
        @builder = SAL::Builder.new(sal_config, builder_params)
      end

      def fetch_results?
        if builder_params.present?
          if params[:fr] == '1'
            :true
          elsif request.referrer.nil? || params[:eager] == '1'
            :eager
          else
            :false
          end
        else
          :false
        end
      end

      def eager?
        fetch_results? == :eager
      end

      def fetching?
        fetch_results? == :true
      end

      def eager_or_fetching?
        eager? || fetching?
      end      

  end

end

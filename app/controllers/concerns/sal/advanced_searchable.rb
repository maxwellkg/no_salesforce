module SAL::AdvancedSearchable
  extend ActiveSupport::Concern

  included do

    helper_method :eager?, :fetching?, :eager_or_fetching?

    def index
      set_page_number
      set_num_results_per_page

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

      def user_input_params
        params.permit(allowable_params)
      end      

      def builder_params(should_paginate: true)
        bps = user_input_params

        if should_paginate && fetching?
          bps.merge!(limit: @num_results_per_page)

          if @page_number > 1
            offset = @num_results_per_page * (@page_number - 1)
            bps.merge!(offset: offset)
          end
        end

        bps
      end

      def sal_config
        sal_config_klass.instance
      end            

      def set_builder
        @builder = SAL::Builder.new(sal_config, builder_params)
      end

      def fetch_results
        if params[:fr] == "1"
          :true
        elsif params[:eager] == "1"
          :eager
        elsif user_input_params.present? && request.referrer.nil?
          :eager
        else
          :false
        end
      end

      def eager?
        fetch_results == :eager
      end

      def fetching?
        fetch_results == :true
      end

      def eager_or_fetching?
        eager? || fetching?
      end

      NUM_RESULTS_PER_PAGE = 25.freeze   

      def set_num_results_per_page
        @num_results_per_page = NUM_RESULTS_PER_PAGE
      end

      def set_page_number
        @page_number = params[:page]&.to_i || 1
      end      

  end

end

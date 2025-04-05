module SAL::Analyzable
  extend ActiveSupport::Concern

  # Note: the following methods should be defined by the
  # including class: #sal_config, #title

  included do

    helper_method :eager_or_fetching?, :eager?, :fetching?
    helper_method :user_can_run_search?, :under_free_page_limit?, :under_free_search_limit?

    def show
      prevent_spam

      set_up

      if eager_or_fetching?
        if user_can_run_search?
          execute_if_fetching
        else
          setup_contact_request
        end
      end

      @presenter = @builder.present

      render_show_view
    end

    def change_mode
      set_builder

      render "sal/builders/change_modes"
    end

    private

      def setup_contact_request
        @contact_request = ContactRequest.new(message: "I'd like to learn more about the #{@title} dataset")
      end

      def render_show_view
        render "sal/show"
      end

      def set_up
        set_fetch_results
        
        if eager_or_fetching?
          set_page_number
          set_num_results_per_page
        end

        set_builder
        set_title
      end

      def dashboard_mode?
        params[:mode] == "dashboard"
      end

      def eager?
        @fetch_results == :eager
      end

      def fetching?
        @fetch_results == :true
      end

      def eager_or_fetching?
        return false if dashboard_mode?

        eager? || fetching?
      end

      NUM_RESULTS_PER_PAGE = 50.freeze

      def builder_params(should_paginate: true)
        bp = analytics_params

        if should_paginate && fetching?
          bp.merge!(row_limit: @num_results_per_page)
          bp.merge!(offset: @num_results_per_page * (@page_number - 1)) if @page_number > 1
        end

        bp
      end

      def builder_klass
        SAL::Builder
      end

      def set_builder
        @builder = builder_klass.new(sal_config, builder_params)
      end

      def set_title
        @title = sal_config.title
      end

      def fetching?
        @fetch_results == :true
      end

      def execute
        @builder.execute!

        increment_cookie_search_count
      end

      def execute_if_fetching
        if fetching?
          set_downloadable

          execute
        end
      end

      def set_fetch_results
        @fetch_results =  if analytics_params.present?
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

      def sal_config
        sal_config_klass.instance
      end

      def filterable_params
        sal_config.searchable_and_filterable_settings.map do |k, v|
          dim = SAL::Dimension.find_by_name(sal_config.klass, k)
          v.dig(:options, :allow_multiple) || dim.date_col? || v.dig(:options, :user_inputs_operator) ? { k => [] } : k
        end
      end

      def groupable_params
        [:rows, :cols]
      end

      def allowable_params
        [
          :mode,
          :metric,
          filterable_params,
          groupable_params,
          :show_values_as,
          :period_1,
          :period_2,
          { display_attributes: [] },
          { order: [] },
          :dashboard_name
        ].flatten
      end

      def analytics_params
        params.permit(allowable_params)
      end

      def set_page_number
        @page_number = params[:page]&.to_i || 1
      end

      def set_num_results_per_page
        @num_results_per_page = NUM_RESULTS_PER_PAGE
      end

      def set_downloadable
        @downloadable = true
      end

      MAX_FREE_SEARCHES = 5.freeze
      MAX_FREE_PAGES = 2.freeze

      def cookie_search_count
        # memoize this as we care about what the search count was at the beginning
        # of this action, not the end (it will get incremented as the query is executed)

        @_cookie_search_count ||= cookies.signed[:search_count] || 0
      end

      def increment_cookie_search_count
        cookies.signed[:search_count] = cookie_search_count + 1
      end

      def under_free_search_limit?
        cookie_search_count <= MAX_FREE_SEARCHES
      end

      def under_free_page_limit?
        @page_number <= MAX_FREE_PAGES
      end

      def within_non_user_limits?
        under_free_page_limit? && under_free_search_limit?
      end

      def user_can_run_search?
        authenticated? || within_non_user_limits?
      end

      def prevent_spam
        redirect_on_spam if params[:honeypot].present?
      end

      def redirect_on_spam
        redirect_to root_path and return
      end

      def mode
        m = params[:mode]

        unless sal_config.allowable_modes.include?(m)
          raise ArgumentError.new("#{m} is not an allowable mode! Allowable modes are: #{sal_config.allowable_modes.join(', ')}")
        end

        m
      end

  end

end

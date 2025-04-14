module SAL::Analyzable
  extend ActiveSupport::Concern

  # Note: the following methods should be defined by the
  # including class: #sal_config, #title

  included do
    helper_method :eager_or_fetching?, :eager?, :fetching?, :user_can_run_search?
  end

  def index
    prevent_spam

    set_up

    execute_if_fetching if eager_or_fetching? && user_can_run_search?

    @presenter = @builder.present

    render_index_view
  end

  def change_mode
    set_builder

    render "sal/builders/change_modes"
  end

  private

    def render_index_view
      render "sal/index"
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
      @downloadable = false
    end

    def user_can_run_search?
      authenticated?
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

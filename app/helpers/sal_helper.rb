module SALHelper

  def sal_results_outer_id
    'sal-results-outer'
  end

  def sal_results_tf_tag_id
    'sal-results'
  end

  def sal_results_tf_tag
    if eager?
      # the results may take a while to fetch, so load them separately
      turbo_frame_tag sal_results_tf_tag_id, src: incoming_path.merge(builder_link_params.merge(fr: 1, page: @page_number)) do
        render partial: 'shared/spinner'
      end
    elsif fetching?
      turbo_frame_tag sal_results_tf_tag_id do
        render partial: "sal/results"
      end
    else
      turbo_frame_tag sal_results_tf_tag_id do
        render partial: "sal/results/not_yet_submitted"
      end
    end
  end 

  def builder_link_params
    @builder.params
  end

  def sal_results_table_partial
    "#{@builder.klass.model_name.collection}/advanced_search_results"
  end

  def sal_results_header
    "#{@builder.num_total_results} Matching #{@builder.config.countable.capitalize}"
  end

  def new_resource_button
    resource_name = @builder.klass.to_s.demodulize.titleize

    link_to(
      "Create New #{resource_name}",
      url_for(action: :new),
      class: "text-white text-lg bg-tangelo-300 hover:bg-tangelo-500 focus:ring-4 focus:outline-none focus:ring-sky-300 font-medium rounded-lg text-md w-2/3 px-5 py-2.5 text-center"
    )
  end

  def show_new_resource_button?
    @builder.config.show_new_resource_button?
  end


##########################################
  def selected_dashboard
    @builder.existing_value(:dashboard_name) || @builder.config.default_dashboard
  end

  def dashboard_options
    @builder.config.settings[:dashboards].map do |d_name, d_settings|
      [d_settings[:title], d_name]
    end
  end

  def analysis_download_cr_message
    "I'm interested in the #{@builder.config.title} dataset download"
  end

  def analysis_download_button_id
    "#{@builder.config.title.delete(" ").underscore.dasherize}-download"
  end

  def over_free_page_limit?
    !under_free_page_limit?
  end

  def over_free_search_limit?
    !under_free_search_limit?
  end

  def sal_over_limit_message
    limited = if over_free_search_limit?
                "free searches"
              elsif over_free_page_limit?
                "free pages for this search"
              end

    "you have reached your maximum number of #{limited}"
  end

  def sal_form_select_tag_html_classes
    "bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5"
  end

  def sal_form_mode_select_options
    @builder.config.allowable_modes.map do |mode|
      [mode.to_s.titleize, mode]
    end
  end

  def sal_form_mode_select_tag
    select_tag(
      :mode,
      options_for_select(sal_form_mode_select_options, selected: @builder.mode),
      class: sal_form_select_tag_html_classes,
      id: "mode-selector",
      required: true,
      data: { action: "change->sal-modes#changeMode" }
    )
  end

  def sal_results_thead_partial
    "sal/results/thead/#{@presenter.builder.mode}"
  end

  def sal_results_tbody_partial
    "sal/results/tbody/#{@presenter.builder.mode}"
  end

  def empty_results_tf_tag
    turbo_frame_tag sal_results_tf_tag_id
  end

  def dashboard_mode?
    @builder.mode == :dashboard
  end

  def change_over_time_row_options
    @builder
      .config
      .groupable_settings
      .reject { |k, v| k == "month" }
      .map { |k, v| [v[:display_name], k] }
  end

  def change_over_time_rows_tag(**html_opts)
    select_tag(
      :rows,
      options_for_select(change_over_time_row_options, @builder.existing_value(:rows)),
      { include_blank: true }.merge(html_opts)
    )
  end

  def summarize_by_select_tag(rows_or_cols)
    param = rows_or_cols

    raise "#{rows_or_cols} is not a valid parameter" unless ['rows', 'cols'].include?(rows_or_cols)

    select_tag(
      param,
      options_for_select(@builder.config.groupable_settings.map { |k, v| [v[:display_name], k] }, @builder.existing_value(param.to_sym)),
      include_blank: true,
      multiple: false,
      class: 'bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5',
      id: "sb-select-#{param}",
      data: {
        #controller: 'ts',
        action: 'change->sal-form#updateShowValuesAs'
      }
    )
  end

  def label_tag_for_groupable(groupable)    
    label_tag id_for_filter(groupable), display_name, class: 'block mb-2 text-md font-medium text-gray-900'
  end

  def groupable_header_name(dim_name, object)
    transformation = @builder.config.groupable_settings.dig(dim_name, :result_options, :display_transformation)

    transformation.nil? ? object : transformation.to_proc.call(object)
  end

  def analysis_column_headers
    # when the analysis has two group bys, the first header will be blank,
    # followed by all the possible values for the second group by
    if @builder.num_group_bys == 2
      groupby2_values = @presenter.results_keyed_by_objects.map do |k, v|
        v.keys
      end.flatten.uniq.sort

      { nil => nil }.merge(groupby2_values.each_with_object({}) { |value, hsh| hsh[groupable_header_name(@builder.group_bys.second, value)] = value })
    else
      # when there is only one group by, the first header should be the display name
      # of the first group by, followed by the names of the metrics
      fgb_display_name = @builder.config.groupable_settings[@builder.group_bys.first][:display_name]
      
      metric = @presenter.analysis.instance_variable_get('@metric')
      metric_header = { metric[:alias].titleize => metric[:alias] }

      { fgb_display_name => nil }.merge(metric_header)
    end
  end

  def row_header_display(row_header)
    row_header.nil? ? "Unavailable" : groupable_header_name(@builder.group_bys.first, row_header)
  end

  def incoming_path
    Rails.application.routes.recognize_path request.path
  end

  # TODO: MKG 21/02/24
  # reconsider how we implement this so that we can reuse in things like CSV downloads
  #
  #
  # if showing values as a calculation, show as a percentage to two decimal places
  # if the config specifies a transformation, apply it
  # if a numeric value, display with commas as a separator
  # else, display the value as-is

  def value_display(value)
    return if value.nil?

    if @presenter.builder.show_values_as != :no_calculation
      number_to_percentage(value * 100, precision: 2)
    else
      config = @presenter.builder.config
      
      metric =  if @presenter.is_a?(SAL::DashboardWidgetPresenter)
                  @presenter.builder.builder.metric
                else
                  @presenter.builder.metric
                end

      transf = @presenter.builder.config.settings_for_metric(metric).dig(:result_options, :display_transformation)

      if transf.present?
        t = transf.to_proc

        instance_exec value, &t
      else
        if value.is_a?(Numeric)
          number_with_delimiter(value)
        else
          value
        end
      end
    end
  end

  def downloadable?
    @builder.config.downloadable?
  end

  def analysis_exports_path
    {
      controller: incoming_path[:controller].split('/').insert(-2, 'exports').join('/'),
      action: :create
    }
  end

=begin
  def analysis_download_button
    modal_button(
      target_id: 'new-export',
      text: 'Download',
      path: analysis_exports_path,
      path_params: @presenter.builder.params,
      class: button_class('violet')
    )
  end
=end

  # allow users to download, but those not logged in should be prompted to contact us to discuss
  # instead

  def analysis_download_button_method
    user_signed_in? ? :post : :get
  end

  def analysis_download_button_path
    user_signed_in? ? analysis_exports_path.merge(builder_link_params) : new_contact_request_path
  end

  def analysis_download_button
    if user_signed_in?
      button_to(
        'Download',
        analysis_download_button_path,
        class: button_class('violet'),
        data: {
          turbo_method: analysis_download_button_method,
          turbo: false # need to render as html else the file will not be sent to the browser correctly
        }
      )
    else
      link_to(
        'Download',
        new_contact_request_path(message: "I'm interested in learning more about the #{@builder.config.title} dataset"),
      )
    end
  end

  def create_analysis_download_path
    { controller: incoming_path[:controller], action: :create }
  end

  def metric_select_tag
    select_tag(
      'metric',
      options_for_select(@builder.config.metric_settings.map { |name, config| [config[:display_name] || name.titleize, name] }, @builder.metric),
      multiple: false,
      class: 'bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5'
      #data: { controller: 'ts' }
    )
  end

  def show_values_as_display(show_values_as)
    show_values_as.to_s.titleize.gsub('Pct', 'Percent')
  end

  # picklist options for show values as
  # by default, all but 'No Calculation' are displayed but disabled
  # enabling those options is handled by a stimulus controller
  # which determines with of the calculations are valid based on whether rows/columns/both are selected
  def show_values_as_select_tag
    opts = SAL::Summary::SHOW_VALUES_AS_OPTIONS.map { |o| [show_values_as_display(o), o] }

    select_tag(
      'show_values_as',
      options_for_select(opts, selected: :no_calculation, disabled: opts.map(&:second).excluding(:no_calculation)),
      multiple: false,
      class: 'bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5',
      id: 'show-values-as'
    )
  end

  def org_search_results_id
    "org-search-results"
  end



  FILTER_OPERATOR_OPTIONS = {
    '=' => 'eq',
    '<' => 'lt',
    '<=' => 'lteq',
    '>' => 'gt',
    '>=' => 'gteq',
    'between' => 'between'
  }

  def select_tag_for_filter_with_operator(dim_name)
    select_tag(
      "#{dim_name}[]",
      options_for_select(FILTER_OPERATOR_OPTIONS, selected: existing_value_for_dimension(dim_name)&.first),
      multiple: false,
      include_blank: true,
      class: 'bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5',
      id: id_for_filter(dim_name),
      data: {
        filter_with_operator_target: 'selector',
        action: 'change->filter-with-operator#update'
      }      
    )
  end

  def input_value_tag_for_filter_with_operator(dim_name, position)
    target =  case position
              when 1
                'firstValue'
              when 2
                'secondValue'
              else
                raise "Position should be 1 or 2. Value given is #{position}"
              end

    number_field_tag(
      "#{dim_name}[]",
      existing_value_for_dimension(dim_name)&.fetch(position),
      allow_blank: true,
      disabled: false,
      class: "bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5",
      id: id_for_filter(dim_name, suffix: position),
      data: {
        filter_with_operator_target: target
      }
    )
  end

  def hidden_class_for_filter_with_operator(dim_name)
    Array.wrap(existing_value_for_dimension(dim_name)).any?(&:present?) ? nil : 'hidden'
  end

  def force_month_value
    if @builder.respond_to?(:force_month?)
      @builder.force_month? || false
    else
      false
    end
  end

  def builder
    @builder
  end
  
  def dimension_for_search_or_filter(dimension_name)
    SAL::Field.find_by_name(builder.config.klass, dimension_name)
  end

  def settings_for_filterable(dimension_name)
    builder.config.filterable_settings[dimension_name]
  end

  def settings_for_searchable(dimension_name)
    builder.config.searchable_settings[dimension_name]
  end

  def searchable?(dim_name)
    builder.config.searchable_settings.keys.include?(dim_name)
  end

  def date_window_selects(dim_name)
    DatePeriod::DATE_WINDOWS.each_with_object({}) do |(text, abbr), hsh|
      end_date = process_date(options_for_filter(dim_name)[:max])

      text_with_date =  if abbr == 'c'
                          text
                        else
                          start_date = abbr == 'at' ? process_date(options_for_filter(dim_name)[:min]) : (end_date - DatePeriod::DATE_WINDOW_PERIODS[abbr]).end_of_month + 1.day

                          "#{text}: (#{start_date} to #{end_date})"
                        end

      hsh[text_with_date] = abbr
    end
  end

  def select_tag_for_time_period(dim_name, disabled: false)
    select_tag(
      "#{dim_name}[]",
      options_for_select(date_window_selects(dim_name), existing_value_for_dimension(dim_name)&.first || options_for_filter(dim_name)[:default]),
      include_blank: true,
      multiple: false,
      disabled: disabled,
      class: 'bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5',
      id: "#{id_for_filter(dim_name)}-date-window",
      data: {
        date_window_select_target: 'selector',
        action: 'change->date-window-select#update change->sal-form#forceMonthDimension'
      }
    )
  end

  def date_tags_for_filter(dim_name, disabled: false)
    render partial: 'shared/date_window_select', locals: { dim_name: dim_name, disabled: disabled }
  end

  def user_inputs_operator_for_filter?(dim_name)
    options_for_filter(dim_name)&.fetch(:user_inputs_operator, false)
  end

  def options_given_for_filter?(dim_name)
    settings_for_filterable(dim_name)[:options].present?
  end

  def checkbox_select?(dim_name)
    settings_for_filterable(dim_name)[:checkbox] || false
  end

  def existing_selected?
    @existing.present?
  end  

  def summary_builder?
    @builder.mode == :summary
  end

  def change_over_time_builder?
    @builder.mode == :change_over_time
  end

  def sal_mode_settings_tf
    "sal-form-mode-settings"
  end

  def change_mode_path
    { controller: incoming_path[:controller], action: :change_mode }
  end

  def change_mode_url_value
    Rails.application.routes.url_helpers.url_for(**change_mode_path.merge(only_path: true))
  end

  def settings_section_partial
    "sal/builders/#{@builder.mode}_settings"
  end

end

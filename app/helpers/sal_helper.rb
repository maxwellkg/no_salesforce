module SALHelper

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

  def sal_form_section(id: nil)
    content_tag :div, id: id, class: "border-b border-gray-300 dark:border-gray-900" do
      content_tag :div, class: "p-6" do
        yield
      end
    end
  end

  def sal_form_submit_tag
    submit_tag(
      submit_tag_text,
      class: "text-white text-lg bg-cornflower-blue-300 hover:bg-cornflower-blue-500 focus:ring-4 focus:outline-none focus:ring-sky-300 font-medium rounded-lg text-md w-2/3 px-5 py-2.5 text-center"
      )
  end

  # TODO 03/03/2025 MKG
  # fix this up

  def should_render_sal_form?
    true
  end

  # TODO: 24/01/23 MKG something better here
  def submit_tag_text
    "Submit"
  end

  def sal_results_outer_id
    'sal-results-outer'
  end

  def sal_results_tf_tag_id
    'sal-results'
  end

  def sal_results_thead_partial
    "sal/results/thead/#{@presenter.builder.mode}"
  end

  def sal_results_tbody_partial
    "sal/results/tbody/#{@presenter.builder.mode}"
  end

  # TODO: MKG 25/02/25
  # cleanup the params that we send  

  def builder_link_params
    @builder.params.except(:row_limit, :offset).merge(mode: @builder.mode)
  end

  def empty_results_tf_tag
    turbo_frame_tag sal_results_tf_tag_id
  end

  def dashboard_mode?
    @builder.mode == :dashboard
  end

  def sal_results_tf_tag
    if dashboard_mode?
      turbo_frame_tag sal_results_tf_tag_id do
        render partial: "sal/dashboard"
      end
    elsif eager_or_fetching?
      if user_can_run_search?
        if eager?
          # the results may take a few seconds to fetch, so load them separately
          turbo_frame_tag sal_results_tf_tag_id, src: incoming_path.merge(builder_link_params.merge(fr: 1, page: @page_number, mode: @builder.mode, display_attributes: @builder.display_attributes)) do
            render partial: 'shared/spinner'
          end
        elsif fetching?
          turbo_frame_tag sal_results_tf_tag_id do
            render partial: "sal/results"
          end
        end
      else
        turbo_frame_tag sal_results_tf_tag_id do
          render partial: "sal/results/over_limit"
        end
      end
    else
      turbo_frame_tag sal_results_tf_tag_id do
        render partial: "sal/results/not_yet_submitted"
      end
    end
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
    'org-search-results'
  end

  def sal_form_target_frame
    sal_results_outer_id
  end

  def sal_form_controller
    'sal-form' unless advanced_search?
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

  def existing_value_for_dimension(dim_name)
    builder.existing_value(dim_name)
  end

  def id_for_filter(dim_name, suffix: nil)
    dimension = dimension_for_search_or_filter(dim_name)
    "#{dimension.name.dasherize.gsub('.', '-')}#{'-' + suffix.to_s if suffix.present?}"
  end

  def searchable?(dim_name)
    builder.config.searchable_settings.keys.include?(dim_name)
  end

  def label_tag_for_search_or_filter(dim_name)
    settings = searchable?(dim_name) ? settings_for_searchable(dim_name) : settings_for_filterable(dim_name)
    display_name = settings[:display_name] || dimension_for_search_or_filter(dim_name).display_name
    label_tag id_for_filter(dim_name), display_name, class: "block mb-2 text-md font-medium text-gray-800 dark:text-white"
  end

  def date_label(date_position)
    if date_position == 'start'
      "On or after"
    elsif date_position == 'end'
      "on or before"
    end
  end

  def process_date(date_obj)
    if date_obj.is_a? Date
      date_obj
    elsif date_obj.is_a? Proc
      date_obj.call
    else
      raise "Unexpected object type: #{date_obj.class}"
    end
  end

  def date_tag_for_filter(dim_name, date_position, disabled: false)
    if date_position == 'start'
      tag_id = "#{id_for_filter(dim_name)}-start"
      current_val = existing_value_for_dimension(dim_name)&.second
    elsif date_position == 'end'
      tag_id = "#{id_for_filter(dim_name)}-end"
      current_val = existing_value_for_dimension(dim_name)&.third
    else
      raise "Unrecognized date position: #{date_position}"
    end

    [
      label_tag(tag_id, date_label(date_position)),
      date_field_tag(
        "#{dim_name}[]",
        existing_value_for_dimension(dim_name),
        min: process_date(options_for_filter(dim_name)[:min]),
        max: process_date(options_for_filter(dim_name)[:max]),
        disabled: disabled,
        class: 'mx-2 bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 p-2.5',
        id: tag_id
      )
    ]
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

  def options_for_filter(dim_name)
    settings_for_filterable(dim_name)[:options] || {}
  end

  def options_for_filter?(dim_name)
    [:collection, :for_select].any? do |key|
      options_for_filter(dim_name).keys.include?(key)
    end
  end

  def user_inputs_operator_for_filter?(dim_name)
    options_for_filter(dim_name)&.fetch(:user_inputs_operator, false)
  end

  def select_options_for_filter(dim_name)
    opts = options_for_filter(dim_name)

    if typeahead_select?(dim_name)
      settings = settings_for_filterable(dim_name)
      
      dim = dimension_for_search_or_filter(dim_name)

      existing_objects = dim.klass.where(id: existing_value_for_dimension(dim_name))

      options_from_collection_for_select(
        existing_objects,
        settings.dig(:options, :value_method),
        settings.dig(:options, :text_method),
        existing_value_for_dimension(dim_name)
      )
    elsif opts[:collection]
      options_from_collection_for_select(
        opts[:collection].call,
        opts[:value_method],
        opts[:text_method],
        existing_value_for_dimension(dim_name)
      )
    else
      options_for_select(opts[:for_select] || [], existing_value_for_dimension(dim_name))
    end
  end

  def multiple_options_for_filter?(dim_name)
    options_for_filter(dim_name)[:allow_multiple] || false
  end

  def select_tag_for_filter(dim_name, disabled: false)
    select_tag(
      dim_name,
      select_options_for_filter(dim_name),
      include_blank: true,
      multiple: multiple_options_for_filter?(dim_name),
      disabled: disabled,
      class: 'bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5',
      id: id_for_filter(dim_name)
      #data: { controller: 'ts' }
    )
  end

  def typeahead_tag_for_filter(dim_name, disabled: false)
    settings = settings_for_filterable(dim_name)

    
    value_method = settings.dig(:options, :value_method)
    text_method = settings.dig(:options, :text_method)
    typeahead_path = Rails.application.routes.url_helpers.send(settings[:path], { value_method: value_method, text_method: text_method })

    dim_value = dim_name.dasherize.gsub('.', '-')

    content_tag :div, id: "#{dim_name}-typeahead-wrapper", data: { controller: 'typeahead-select', typeahead_select_url_value: typeahead_path, typeahead_select_dimension_value: dim_value } do
      select_tag(
        dim_name,
        select_options_for_filter(dim_name),
        include_blank: true,
        multiple: multiple_options_for_filter?(dim_name),
        disabled: disabled,
        id: id_for_filter(dim_name),
        placeholder: "Search",
        data: {
          typeahead_select_target: 'select'
        }
      )
    end
  end

  def text_tag_for_search_or_filter(dim_name, disabled: false)
    text_field_tag(
      dim_name,
      existing_value_for_dimension(dim_name),
      allow_blank: true,
      disabled: disabled,
      class: "bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5",
      id: id_for_filter(dim_name)
    )
  end

  alias_method :text_tag_for_filter, :text_tag_for_search_or_filter
  alias_method :text_tag_for_search, :text_tag_for_search_or_filter


  def options_given_for_filter?(dim_name)
    settings_for_filterable(dim_name)[:options].present?
  end

  def typeahead_select?(dim_name)
    settings_for_filterable(dim_name)[:typeahead] || false
  end

  def checkbox_select?(dim_name)
    settings_for_filterable(dim_name)[:checkbox] || false
  end

  def date_filter?(dim_name)
    dimension_for_search_or_filter(dim_name).date_col?
  end

  def input_tag_for_filter(dim_name, disabled: false)
    if searchable?(dim_name)
      text_tag_for_filter(dim_name, disabled: disabled)
    elsif date_filter?(dim_name)
      date_tags_for_filter(dim_name, disabled: disabled)
    elsif typeahead_select?(dim_name)
      typeahead_tag_for_filter(dim_name, disabled: disabled)
    elsif options_for_filter?(dim_name)
      # if options are given
      select_tag_for_filter(dim_name, disabled: disabled)
    else
      # if there are no other options, leave it up to the user to manually input their value
      text_tag_for_filter(dim_name, disabled: disabled)
    end
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

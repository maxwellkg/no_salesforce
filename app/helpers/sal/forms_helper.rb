module SAL::FormsHelper

  def sal_form_section(id: nil)
    content_tag :div, id: id, class: "border-b border-gray-300 dark:border-gray-900" do
      content_tag :div, class: "p-6" do
        yield
      end
    end
  end

  def sal_form_submit_tag
    submit_tag(
      "Submit",
      class: "text-white text-lg bg-cornflower-blue-300 hover:bg-cornflower-blue-500 focus:ring-4 focus:outline-none focus:ring-sky-300 font-medium rounded-lg text-md w-2/3 px-5 py-2.5 text-center"
    )
  end

  def sal_form_target_frame
    sal_results_outer_id
  end 

  def sal_form_controller
    "sal-form"
  end

  def id_for_filter(name)
    name.to_s.dasherize.gsub('.', '-')
  end

  def label_tag_for_search_or_filter(name, label)
    label_tag(
      id_for_filter(name),
      label,
      class: "block mb-2 text-md font-medium text-gray-800 dark:text-white"
    )
  end

  def existing_value_for_field(field_name)
    @builder.existing_value(field_name)
  end  

  def input_tag_for_search(searchable_hsh)
    field_name = searchable_hsh[:search_method]

    search_field_tag(
      field_name,
      existing_value_for_field(field_name),
      allow_blank: true,
      class: "bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5",
      id: id_for_filter(field_name)
    )
  end

  def label_and_input_tags_for_search(searchable_hsh)
    content_tag :div, class: "py-4" do
      [
        label_tag_for_search_or_filter(searchable_hsh[:search_method], searchable_hsh[:label]),
        input_tag_for_search(searchable_hsh)
      ].join.html_safe
    end.html_safe
  end

  def column_for_field_name(field_name)
    @builder.config.column_for_field_name(field_name)
  end

  def boolean_filter?(field_name)
    col = column_for_field_name(field_name)

    return false unless col.present?

    col.type == :boolean
  end

  def date_filter?(field_name)
    col = column_for_field_name(field_name)

    return false unless col.present?

    [:date, :datetime].include?(col.type)
  end

  def date_label(field_label, date_position)
    if date_position == 'start'
      "#{field_label} on or after"
    elsif date_position == 'end'
      "#{field_label} on or before"
    end
  end

  def process_date(date_obj)
    return if date_obj.nil?

    case date_obj
    when Date
      date_obj
    when Proc
      date_obj.call
    else
      raise "Unexpected object type: #{date_obj.class}"
    end
  end

  def tags_for_date_filter(filter_hsh, date_position)
    field_name = filter_hsh[:field]
    field_label = filter_hsh[:label]

    if date_position == 'start'
      tag_id = "#{id_for_filter(field_name)}-start"
      current_val = existing_value_for_field(field_name)&.first
    elsif date_position == 'end'
      tag_id = "#{id_for_filter(field_name)}-end"
      current_val = existing_value_for_field(field_name)&.second
    else
      raise "Unrecognized date position: #{date_position}"
    end

    [
      label_tag(tag_id, date_label(field_label, date_position)),
      date_field_tag(
        "#{field_name}[]",
        current_val,
        min: process_date(filter_hsh.dig(:options, :min)),
        max: process_date(filter_hsh.dig(:options, :max)),
        class: 'mx-2 bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 p-2.5',
        id: tag_id
      )
    ].join.html_safe
  end  

  def label_and_input_tags_for_date_field(filter_hsh)
    ['start', 'end'].map do |pos|
      content_tag :div, class: "py-4" do
        tags_for_date_filter(filter_hsh, pos)
      end
    end.join.html_safe
  end

  def typeahead_select?(filter_hsh)
    filter_hsh[:typeahead] || false
  end

  def multiple_options_for_filter?(filter_hsh)
    filter_hsh.dig(:options, :allow_multiple) || false
  end

  def options_for_filter(filter_hsh)
    filter_hsh[:options] || {}
  end  

  def select_options_for_filter(filter_hsh)
    field_name = filter_hsh[:field]
    opts = options_for_filter(filter_hsh)

    if typeahead_select?(filter_hsh)
      existing_objects = @builder.klass_for_filter(field_name).where(id: existing_value_for_field(field_name))

      options_from_collection_for_select(
        existing_objects,
        filter_hsh.dig(:options, :value_method),
        filter_hsh.dig(:options, :text_method),
        existing_value_for_field(field_name)
      )
    elsif opts[:collection]
      options_from_collection_for_select(
        opts[:collection].call,
        opts[:value_method],
        opts[:text_method],
        existing_value_for_field(field_name)
      )
    else
      for_select = opts[:for_select] || []
      options_for_select(for_select, existing_value_for_field(field_name))
    end
  end  

  def typeahead_tag_for_filter(filter_hsh)
    value_method = filter_hsh.dig(:options, :value_method)
    text_method = filter_hsh.dig(:options, :text_method)
    typeahead_path = Rails.application.routes.url_helpers.send(filter_hsh[:path], { value_method: value_method, text_method: text_method })

    field_name = filter_hsh[:field]
    dim_value = field_name.to_s.dasherize.gsub('.', '-')

    

    content_tag :div, id: "#{field_name.to_s.dasherize}-typeahead-wrapper", data: { controller: 'typeahead-select', typeahead_select_url_value: typeahead_path, typeahead_select_dimension_value: dim_value } do
      select_tag(
        field_name,
        select_options_for_filter(filter_hsh),
        include_blank: true,
        multiple: multiple_options_for_filter?(filter_hsh),
        id: id_for_filter(field_name),
        placeholder: "Search",
        data: {
          typeahead_select_target: 'select'
        }
      )
    end.html_safe
  end

  def options_for_filter?(filter_hsh)
    [:collection, :for_select].any? do |key|
      options_for_filter(filter_hsh).keys.include?(key)
    end
  end

  def select_tag_for_filter(filter_hsh)
    field_name = filter_hsh[:field]

    select_tag(
      field_name,
      select_options_for_filter(filter_hsh),
      include_blank: true,
      multiple: multiple_options_for_filter?(filter_hsh),
      class: 'bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5',
      id: id_for_filter(field_name)
    )
  end

  def text_tag_for_search_or_filter(field_name)
    text_field_tag(
      field_name,
      existing_value_for_field(field_name),
      allow_blank: true,
      class: "bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5",
      id: id_for_filter(field_name)
    )
  end   

  def input_tag_for_filter(filter_hsh)
    if typeahead_select?(filter_hsh)
      typeahead_tag_for_filter(filter_hsh)
    elsif options_for_filter?(filter_hsh)
      # options are given in the field configuration
      select_tag_for_filter(filter_hsh)
    else
      # if there are no other options, leave it up to the user to manually input their value
      text_tag_for_filter(filter_hsh[:field])
    end
  end

  def label_and_input_tags_for_filter(filter_hsh)
    field_name = filter_hsh[:field]

    if date_filter?(field_name)
      label_and_input_tags_for_date_field(filter_hsh)
    else
      content_tag :div, class: "py-4" do
        [
          label_tag_for_search_or_filter(field_name, filter_hsh[:label]),
          input_tag_for_filter(filter_hsh)
        ].join.html_safe
      end.html_safe
    end
  end

  def label_and_input_tags_for_scopable(scopable_hsh)
    group_name = scopable_hsh[:name]

    allow_multiple = scopable_hsh.dig(:options, :allow_multiple) || false

    content_tag :div, class: "py-4" do
      [
        label_tag_for_search_or_filter(group_name, scopable_hsh[:label]),
        select_tag(
          group_name,
          options_for_select(scopable_hsh.dig(:options, :scopes), existing_value_for_field(group_name)),
          include_blank: true,
          multiple: allow_multiple,
          class: "bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5",
          id: id_for_filter(group_name)
        )
      ].join.html_safe
    end.html_safe
  end

end

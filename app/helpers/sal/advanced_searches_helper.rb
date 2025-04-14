module SAL::AdvancedSearchesHelper

  def change_order_link_to(attribute)
    settings = @builder.config.displayable_settings[attribute]

    link_to(
      settings[:display_name],
      change_order_link_for_attribute(attribute),
      class: 'inline-block dark:text-white',
      data: {
        turbo_frame: sal_form_target_frame,
        turbo_action: "advance"
      }
    )
  end

  # if display attributes have been specified, use those
  # else select the default

  def display_attributes_with_settings
    @builder.config.displayable_settings.select do |k, v|
      @builder.display_attributes.include?(k)
    end
  end

  def display_attribute_options
    @builder.config.displayable_settings.map do |att_name, opts|
      [opts[:display_name], att_name]
    end
  end

  def selected_display_attributes
    existing = @builder.existing_value(:display_attributes)

    existing.present? ? existing : @builder.config.default_display_attributes
  end

  def change_order_link_params(col, order)
    builder_link_params.merge({ eager: '1', order: [col, order]})
  end

  def current_order_col
    @builder.params[:order]&.first&.to_sym
  end

  def currently_ordered_by_attribute?(attribute)
    current_order_col == attribute.to_sym
  end

  def current_order_direction
    @builder.params[:order]&.second&.to_sym
  end

  def change_order_link_for_attribute(attribute)
    co_params = if currently_ordered_by_attribute?(attribute)
                  order = if current_order_direction == :desc
                            :asc
                          else
                            :desc
                          end

                  change_order_link_params(attribute, order)
                else
                  change_order_link_params(attribute, :desc)
                end

    Rails
      .application
      .routes
      .recognize_path(request.path)
      .merge(co_params)
  end

  def order_arrow_icon(css_class: nil)
    arrow_dir = case current_order_direction
                when :asc
                  'up'
                when :desc
                  'down'
                end

    image_tag "arrow-#{arrow_dir}-solid.svg", size: 16, class: css_class
  end

  def attribute_transformed_for_display(attribute, org)
    transf = @builder.config.displayable_settings.dig(attribute, :result_options, :display_transformation)

    if transf.present?
      instance_exec org, &transf
    else
      dim = SAL::Dimension.find_by_name(@builder.config.klass, attribute) rescue nil

      if dim.present?
        if dim.reflection?
          org.send(dim.reflection.name)&.send(dim.column_name)
        else
          org.send(dim.name)
        end
      else
        org.send(attribute)
      end
    end      
  end   

end

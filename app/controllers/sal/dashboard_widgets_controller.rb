class SAL::DashboardWidgetsController < ApplicationController
  allow_unauthenticated_access

  def show
    widget = build_widget
    widget.execute!

    @widget_id = widget_params[:id]

    @presenter = widget.present
  end

  private

    def sal_config_klass
      SAL.find_config(params[:config])
    end

    def sal_config
      sal_config_klass.instance
    end

    def filterables
      sal_config.searchable_and_filterable_settings
    end

    def filterable_params
      filterables.map do |k, v|
        dim = SAL::Dimension.find_by_name(sal_config.klass, k)
        v.dig(:options, :allow_multiple) || dim.date_col? || v.dig(:options, :user_inputs_operator) ? { k => [] } : k
      end
    end

    def allowable_widget_params
      [:id, :dashboard, :widget, filterable_params].flatten
    end

    def widget_params
      params.permit(allowable_widget_params)
    end

    def dashboard_name
      widget_params[:dashboard]
    end

    def widget_name
      widget_params[:widget]
    end

    def conditions
      widget_params.slice(*filterables.keys)
    end

    def build_widget
      SAL::DashboardWidget.new(
        config: sal_config,
        dashboard_name: dashboard_name,
        widget_name: widget_name,
        conditions: conditions
      )
    end

end

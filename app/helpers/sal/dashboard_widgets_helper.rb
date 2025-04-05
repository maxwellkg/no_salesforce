module SAL::DashboardWidgetsHelper

  def dashboard_widget_path(id, config, dashboard_name, widget_name, conditions)
    sal_dashboard_widgets_path(
      id: id,
      config: config,
      dashboard: dashboard_name,
      widget: widget_name,
      **conditions
    )
  end

  def lazy_dashboard_widget(config, dashboard_name, widget_name, conditions)
    id = SecureRandom.hex(4)

    turbo_frame_tag id, src: dashboard_widget_path(id, config, dashboard_name, widget_name, conditions) do
      render partial: "shared/spinner"
    end
  end

  def dashboard_widget_visualization
    if @presenter.metric_visualization?
      render partial: "sal/dashboard_widgets/metric"
    elsif @presenter.table_visualization?
      render partial: "sal/results/table"
    elsif @presenter.chart_visualization?
      chart_without_limit @presenter.visualization_mode, id: "chart-#{@presenter.widget_name.to_s.dasherize}"
    else
      raise "Visualization mode #{@presenter.visualization_mode} has not yet been implemented!"
    end
  end

  def dashboard_widget_metric_display
    value_display(@presenter.table_data.first.first)
  end

end

class SAL::DashboardPresenter

  attr_reader :builder

  delegate :dashboard_name, to: :builder

  def initialize(builder)
    @builder = builder
  end

  def title
    builder.config.settings.dig(:dashboards, dashboard_name, :title)
  end

  def widget_names
    builder.config.settings.dig(:dashboards, dashboard_name, :widgets)&.keys
  end

  def conditions
    builder.params
  end

end

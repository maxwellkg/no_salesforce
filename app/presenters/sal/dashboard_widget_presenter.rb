class SAL::DashboardWidgetPresenter

  attr_reader :widget
  
  delegate :visualization_mode, :builder, :widget_name, to: :widget

  delegate_missing_to :builder

  CHART_TYPES = [:line_chart, :column_chart].freeze

  def initialize(widget)
    @widget = widget
  end

  def title
    widget.title.is_a?(Proc) ? widget.title.call(self) : widget.title
  end

  def metric_visualization?
    visualization_mode == :metric
  end

  def table_visualization?
    visualization_mode == :table
  end

  def chart_visualization?
    CHART_TYPES.include?(visualization_mode)
  end

end

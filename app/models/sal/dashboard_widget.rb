class SAL::DashboardWidget

  attr_reader :config, :widget_name

  delegate :execute!, to: :builder

  VALID_VISUALIZATION_MODES = [:table, :line_chart, :column_chart].freeze

  def initialize(config:, dashboard_name:, widget_name:, conditions:)
    @config = config
    @dashboard_name = dashboard_name
    @widget_name = widget_name
    @conditions = conditions
  end

  def builder
    @builder ||= create_builder
  end

  def present
    present_builder

    SAL::DashboardWidgetPresenter.new(self)
  end

  # get the title from the widget hash

  def title
    widget_hsh[:title]
  end

  # get the visualization mode from the widget hash

  def visualization_mode
    widget_hsh[:visualization_mode]  
  end  

  private

    # get the dashboard hash from the config

    def dashboard_hsh
      config.settings.dig(:dashboards, @dashboard_name)
    end


    # get the widget hash from the dashboard hash

    def widget_hsh
      dashboard_hsh.dig(:widgets, @widget_name)
    end


    # get the query klass from the widget hash

    def query_klass
      widget_hsh[:query_klass]
    end


    # get the query args from the widget hash

    def query_args
      widget_hsh[:query_args]  
    end

    
    # the builder params combine the query settings (defined in the config)
    # with the filters selected by the user (given by the conditions hash)

    def builder_params
      query_args.merge(@conditions)
    end

    def alter_query_conditions(query)
      conds = query.instance_variable_get("@conditions")

      widget_hsh[:condition_alterations]&.each do |k, v|
        conds[k] = v.call(query)
      end
    end


    def create_builder
      builder = SAL::Builder.new(config, builder_params)

      builder.send(:set_query)

      alter_query_conditions(builder.query) if widget_hsh[:condition_alterations].present?

      builder
    end

    def present_builder
      @builder = builder.present
    end

end

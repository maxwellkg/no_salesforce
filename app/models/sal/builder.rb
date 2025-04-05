class SAL::Builder
  attr_reader :config, :params, :mode, :query

  include SAL::Builders::Analyses,
          SAL::Builders::Summaries,
          SAL::Builders::ChangeOverTime,
          SAL::Builders::AdvancedSearches,
          SAL::Builders::Dashboards

  def initialize(config, params)
    @config = config

    set_mode(params.delete(:mode))

    @params = params.to_h.reject do |_, v|
      if v.is_a?(Array)
        v.all?(&:blank?)
      else
        v.blank?
      end
    end.with_indifferent_access    
  end

  def existing_value(dim_name)
    params[dim_name]
  end

  FORCE_MONTH = false.freeze

  def force_month?
    self.class::FORCE_MONTH
  end

  def execute!
    set_query
    @query.execute!
  end

  def present
    presenter_klass.new(self)
  end

  private

    def presenter_klass
      case mode
      when :summary
        SAL::SummaryPresenter
      when :change_over_time
        SAL::ChangeOverTimePresenter
      when :advanced_search
        SAL::AdvancedSearchPresenter
      when :dashboard
        SAL::DashboardPresenter
      end
    end

    def set_mode(mode)
      mode = mode&.to_sym || config.default_mode

      unless config.allowable_modes.include?(mode)
        raise ArgumentError.new("#{mode} is not an allowable mode! Allowable modes are: #{config.allowable_modes.join(', ')}")
      end

      @mode = mode
    end

    def set_query
      @query ||= build_query
    end

    def build_query
      case mode
      when :summary
        build_analysis
      when :change_over_time
        build_change_over_time
      when :advanced_search
        build_advanced_search
      end
    end

    def search_condition_value(param_name, value)
      dim = config.dimension_for_filterable_or_searchable(param_name)

      search_method = config.searchable_settings.dig(param_name, :search_method)

      # should return an ActiveRecord::Relation
      config.klass.send(search_method, value)
    end

    def alter_value_for_query(param_name, value)
      dim = config.dimension_for_filterable_or_searchable(param_name)

      if dim.date_col? && value.is_a?(Array)
        period = value.first

        if period == 'c'
          (value.second.to_date..value.third.to_date)
        else
          max_end = config.filterable_settings[param_name][:options][:max].call

          DatePeriod.period_from_end(max_end, period)
        end
      elsif config.filterable_requires_operator?(param_name)
        operator = value.first.to_sym

        first_val = value.second.to_i
        second_val = value.third&.to_i

        case operator
        when :eq
          first_val
        when :gt
          (first_val.to_f.next_float..)
        when :gteq
          (first_val..)
        when :lt
          (...first_val)
        when :lteq
          (..first_val)
        when :between
          (first_val..second_val)
        else
          raise "#{operator.to_s} is not a recognized operator!"
        end
      elsif config.condition_alterations.has_key?(dim.name)
        alteration = config.condition_alterations[dim.name]
        alteration.call(value)
      else
        value
      end
    end

    def ignore_param?(param_name, value)
      dim = config.dimension_for_filterable_or_searchable(param_name)

      # we allow the user to select "All Time", but this is really the same
      # as not setting a date filter at all, so ignore it
      dim.date_col? && dim.is_a?(Array) && value.first == 'at'
    end

    def process_conditions
      params.each_with_object({}) do |(k, v), hsh|
        if config.searchable_field?(k)
          # when searching, we construct an ActiveRecord::Relation based on the search
          # and create a condition where :primary_key => relation
          hsh[config.klass.primary_key] = search_condition_value(k, v)
        elsif config.searchable_or_filterable_field?(k) && !ignore_param?(k, v)
          hsh[k] = alter_value_for_query(k, v)
        end
      end
    end

end

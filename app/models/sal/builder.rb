class SAL::Builder

  attr_reader :config, :params

  delegate :klass, :title, :searchables, :searchable_method?, :filterables, :filterable_field?, :klass_for_filter, to: :config

  def initialize(config, params)
    @config = config

    @params = params.to_h.reject do |k, v|
      case v
      when Array
        v.all?(&:blank?)
      else
        v.blank?
      end
    end.with_indifferent_access
  end

  def existing_value(param_name)
    params[param_name]
  end

  def query
    query_without_limit
      .order(order_by)
      .limit(limit_to_apply)
      .offset(offset_to_apply)
  end

  alias_method :results, :query

  def num_total_results
    @_total ||= query.count
  end

  def no_matching_results?
    num_total_results.zero?
  end

  private

    def query_without_limit
      return @_query if @query.present?

      @_query = klass.all

      apply_search_chain
      apply_filters

      @_query
    end

    def searchable_params
      params.select { |k, _| searchable_method?(k) }
    end

    def apply_search_chain
      searchable_params.each do |search_method, search_term|
        @_query = @_query.public_send(search_method, search_term)
      end
    end

    def filterable_params
      params.select { |k, _| filterable_field?(k) }
    end

    # certain conditions need to be transformed from their parameter values into a form
    # that better suits a hash of conditions for ActiveRecord
    #
    # for example, we collect date ranges as an array where the first element is the start
    # date and the second element is the end date, and we need to transform that into a range
    # of date values
    # e.g. { occurring_at: ['2025-01-01', '2025-01-31'] becomes { occurring_at: Wed, 01 Jan 2025..Fri, 31 Jan 2025 }

    def alter_value_for_date_filter(value)
      start_date = value.first&.to_date
      end_date = value.second&.to_date

      (start_date..end_date)
    end

    def alter_value_for_query(param_name, value)
      if config.date_filter?(param_name)
        alter_value_for_date_filter(value)
      else
        value
      end
    end

    def filter_conditions
      filterable_params.each_with_object({}) do |(k, v), hsh|
        hsh[k] = alter_value_for_query(k, v)
      end
    end    

    def apply_filters
      @_query = @_query.where(filter_conditions)
    end

    def limit_to_apply
      params[:limit]
    end

    def offset_to_apply
      params[:offset]
    end

    # order comes as a hash e.g. { col_name => asc_or_desc }
    def order_by
      return unless params[:order].present?

      col_name = params[:order].first
      asc_or_desc = params[:order].second

      klass.arel_table[col_name].send(asc_or_desc).nulls_last
    end

end

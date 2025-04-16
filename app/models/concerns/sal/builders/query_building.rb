module SAL::Builders::QueryBuilding
  extend ActiveSupport::Concern

  def query
    @query = klass.all

    apply_search_chain
    apply_filters

    @query
  end

  private

    def searchable_params
      params.select { |k, _| searchable_method?(k) }
    end

    def apply_search_chain
      searchable_params.each do |search_method, search_term|
        @query = @query.public_send(search_method, search_term)
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
      if date_filter?(param_name)
        alter_value_for_date_filter
      else
        value
      end
    end

    def filter_conditions
      filterable_params.each_with_object({}) do |(k, v), hsh|
        hsh[k] = alter_value_for_query(v)
      end
    end    

    def apply_filters
      @query = @query.where(filter_conditions)
    end
  
end
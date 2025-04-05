module SAL::Builders::ChangeOverTime
  extend ActiveSupport::Concern

  included do

    def date_field
      config.change_over_time_date_field
    end

    def period_1
      params[:period_1]
    end

    def period_2
      params[:period_2]
    end

    def limit
      params[:row_limit]
    end

    def offset
      params[:offset]
    end


    def build_change_over_time
      SAL::ChangeOverTime.new(
        klass: config.klass,
        metric: metric_hsh,
        date_field: date_field,
        period_1: period_1,
        period_2: period_2,
        conditions: process_conditions,
        rows: rows,
        limit: limit,
        offset: offset
      )
    end

  end

end

# methods that are shared between Summary and ChangeOverTime objects
module SAL::Builders::Analyses
  extend ActiveSupport::Concern

  included do
    def metric_hsh
      config.metric_settings.dig(metric, :metric_hsh)
    end
  end

end
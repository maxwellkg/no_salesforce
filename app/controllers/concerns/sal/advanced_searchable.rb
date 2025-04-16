module SAL::AdvancedSearchable
  extend ActiveSupport::Concern

  included do
    helper_method :advanced_search_config
  end

  def index
    set_builder

    render "advanced_searches/index"
  end

  private

    def set_builder
      @builder = SAL::Builder.new(sal_config_klass, {})
    end

    def advanced_search_config
      sal_config_klass.instance
    end

end

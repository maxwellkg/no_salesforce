module SAL::AdvancedSearchable
  extend ActiveSupport::Concern

  included do
    helper_method :advanced_search_config
  end

  def index
    set_title
    set_builder

    render "advanced_searches/index"
  end

  private

    def sal_title
      "Accounts"
    end

    def set_title
      @title = sal_title
    end

    def set_builder
      @builder = SAL::Builder.new(advanced_search_config, {})
    end

    def advanced_search_config
      sal_config_klass.instance
    end

end

class SAL::AdvancedSearchPresenter < ApplicationPresenter

  attr_reader :builder

  delegate :query, to: :builder
  delegate :results, to: :query
  delegate :total_results, to: :query
  delegate :klass, to: :query

  def initialize(builder)
    @builder = builder
  end

  def show_charts?
    false
  end

  def no_matching_results?
    total_results == 0
  end

  def results_header
    "#{number_with_delimiter(total_results)} Matching #{builder.config.countable.pluralize.titleize}"
  end  

end

module SAL::PaginationHelper

  def pagination_link_params(page_number)
    builder_link_params.merge(page: page_number, eager: 1)
  end

  def link_to_page(page_number)
    Rails.application.routes.recognize_path(request.path)
      .merge(pagination_link_params(page_number))
  end

  def total
    @presenter.results.total
  end

  def num_results
    @builder.num_total_results
  end

  def show_countable?
    num_results.present? && !no_results?
  end

  def no_results?
    num_results.blank? || num_results == 0
  end

  def should_paginate?
    num_results.present? && num_results > @num_results_per_page
  end

  def pagination_start
    pg_start = (@page_number - 1) * @num_results_per_page + 1

    number_with_delimiter(pg_start)
  end

  def last_page?
    @page_number == last_page_number
  end

  def pagination_end
    pg_end = if should_paginate?
              if last_page?
                num_results
              else
                @page_number * @num_results_per_page
              end
            else
              num_results
            end

    number_with_delimiter(pg_end)
  end

  def first_page_number
    1
  end

  def previous_page_number
    @page_number == 1 ? @page_number : @page_number - 1
  end

  def last_page_number
    (num_results.to_f / @num_results_per_page).ceil
  end

  def next_page_number
    @page_number == last_page_number ? @page_number : @page_number + 1
  end

  def pagination_resource
    @builder.config.countable.pluralize.titleize
  end

end

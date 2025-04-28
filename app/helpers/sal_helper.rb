module SALHelper

  def sal_results_outer_id
    'sal-results-outer'
  end

  def sal_results_tf_tag_id
    'sal-results'
  end

  def sal_results_tf_tag
    if eager?
      # the results may take a while to fetch, so load them separately
      turbo_frame_tag sal_results_tf_tag_id, src: incoming_path.merge(builder_link_params.merge(fr: 1, page: @page_number)) do
        render partial: 'shared/spinner'
      end
    elsif fetching?
      turbo_frame_tag sal_results_tf_tag_id do
        render partial: "sal/results"
      end
    else
      turbo_frame_tag sal_results_tf_tag_id do
        render partial: "sal/results/not_yet_submitted"
      end
    end
  end 

  def builder_link_params
    @builder.params
  end

  def sal_results_table_partial
    "#{@builder.klass.model_name.collection}/advanced_search_results"
  end

  def sal_results_header
    "#{@builder.num_total_results} Matching #{@builder.config.countable.capitalize}"
  end

  def new_resource_button
    resource_name = @builder.klass.to_s.demodulize.titleize

    link_to(
      "Create New #{resource_name}",
      url_for(action: :new),
      class: "text-white text-lg bg-emerald-900 hover:bg-emerald-700 focus:ring-4 focus:outline-none focus:ring-sky-300 font-medium rounded-lg text-md w-2/3 px-5 py-2.5 text-center"
    )
  end

  def show_new_resource_button?
    @builder.config.show_new_resource_button?
  end

  def incoming_path
    Rails.application.routes.recognize_path request.path
  end  

end

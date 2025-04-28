module SAL::AdvancedSearchesHelper

  def advanced_search_form_tf_id
    "advanced-search-form-tf"
  end

  # the advanced search form will always be submitted to the same
  # path as the request in which the form was rendered

  def advanced_search_form_path
    request.path
  end

end

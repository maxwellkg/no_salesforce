class AdvancedSearch

  attr_reader :klass, :searches, :filters
  attr_accessor :query

  def initialize(klass: , searches: {}, filters: {})
    @klass = klass
    @searches = searches
    @filters = filters
  end

  # set the base scope as .all
  # then apply the searches
  # then appy the filters
  # then return the relation

  def build_query
    self.query = klass.all

    apply_search_chain
    apply_filters

    query
  end

  private

  # the searches hash is constructed with the name of the search method as a key and the
  # search term as the key
  # ex: { search_method_1: "search_term_1", search_method_2: "search_term_2" }
  #
  # the search methods are scopes on the model, so we can put together the search
  # component of the advanced search by chaining the scopes together
  # (the base scope has been set to .all at the beginning of #build_query above)

  def apply_search_chain
    searches.each do |search_method, search_term|
      self.query = self.query.public_send(search_method, search_term)
    end
  end

  def apply_filters
    self.query = self.query.where(filters)
  end

end

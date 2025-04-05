module BasicSearch
  extend ActiveSupport::Concern

  class_methods do

    def basic_search(search_field)
      define_singleton_method(:search) do |search_term|
        where(arel_table[search_field].matches("%#{search_term}%"))
      end
    end

  end

end

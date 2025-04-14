module BasicSearch
  extend ActiveSupport::Concern

  class_methods do

    # basic_search :<field> creates a class method search_<field>
    # implements a simple search using ILIKE against the <field> column,
    # with a wildcard on either side of the search term
    #
    # ex: A User class has a column 'email' to store the user's email
    #
    # class User < ApplicationRecord
    #   basic_search :email
    # end
    #
    # User.search_email("example.com") would return all the users with "example.com"
    # in their email address

    def basic_search(search_field)
      define_singleton_method("search_#{search_field}") do |search_term|
        where(arel_table[search_field].matches("%#{search_term}%"))
      end
    end

  end

end

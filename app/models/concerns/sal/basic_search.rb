module SAL::BasicSearch
  extend ActiveSupport::Concern

  class_methods do

    # basic search creates a scope on that can be used with a search term
    # the scope performs a simple search against the specified columns using ILIKE, with
    # a wildcard on either side of the search term
    #
    # a basic search against a single field can be created without providing arguments for
    # cols—the column will be inferred from the search_name
    # e.g. basic_search :email
    # will assume there is a column named "email" on the model and create a scope .search_email
    # that searches against that field
    #
    # you can create a search on a single field with a name that does not match the column name
    # by providing the search_name and field separately
    # e.g. basic_search :email_address, :email
    # will create a search scope .search_email_address that searches on the email field
    #
    # finally, you can create a basic search across multiple columns by defining all of the columns
    # in the cols
    # e.g. basic_search :full_name, :first_name, :last_name
    # will create a search scope .search_full_name that looks at both first_name and last_name
    #
    #
    # ex: A User class has a column 'email' to store the user's email and columns 'first_name' and 'last_name'
    # to store the user's first and last names, respectively
    #
    # class User < ApplicationRecord
    #   basic_search :email
    #   basic_search :full_name, :first_name, :last_name
    # end
    #
    # User.search_email("example.com") would return all the users with "example.com"
    # in their email address
    #
    # User.search_full_name("joe") would return all users with "joe" in the first OR last names
    #
    # basic_search will raise an error if any of the columns do not exist on the model


    def basic_search(search_name, *cols)
      cols.append(search_name) if cols.empty?

      cols.each do |col|
        raise "Could not find column #{col} on #{self}" unless self.column_names.include?(col.to_s)
      end

      scope_name = "search_#{search_name}"

      search_lambda = lambda do |search_term|
        conditions = cols.map do |col|
          arel_table[col].matches("%#{search_term}%")
        end

        conditions = conditions.reduce { |conditions, cond| conditions.or(cond) }

        where(conditions)
      end

      self.send :scope, scope_name, search_lambda
    end

  end

end

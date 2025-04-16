class Typeaheads::UsersController < ApplicationController
  include Typeaheadable

  private

    def klass
      User
    end

    def search_method
      :search_full_name
    end

end

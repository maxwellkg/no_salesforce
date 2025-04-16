class Typeaheads::AccountsController < ApplicationController
  include Typeaheadable

  private

    def klass
      Account
    end

    def search_method
      :search_name
    end

end

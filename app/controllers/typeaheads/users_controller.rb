class Typeaheads::UsersController < ApplicationController
  include Typeaheadable

  private

    def klass
      User
    end

end

class Typeaheads::ReminderSubjectsController < ApplicationController
  include Typeaheadable

  private

    def klass
      ReminderSubject
    end

    def search_method
      :search_name
    end

end

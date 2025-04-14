ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

# use this sparingly!
require 'minitest/mock'

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...

    def set_current_user(user)
      session = user.sessions.create!
      Current.session = session
    end

    def login_as(user)
      session = set_current_user(user)

      request = ActionDispatch::Request.new(Rails.application.env_config)
      cookies = request.cookie_jar
      cookies.signed[:session_id] = {value: session.id, httponly: true, same_site: :lax}
    end

    def skip_nyi
      skip("Not yet implemented!")
    end

  end
end

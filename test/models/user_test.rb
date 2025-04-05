require "test_helper"

class UserTest < ActiveSupport::TestCase

  test "is invalid without a first name" do
    user = users(:regular)
    user.first_name = nil

    user.valid?

    assert user.errors.where(:first_name).any? { |error| error.type == :blank }
  end

  test "is invalid without a last name" do
    user = users(:regular)
    user.last_name = nil

    user.valid?

    assert user.errors.where(:last_name).any? { |error| error.type == :blank }
  end

  test "is invalid without an email" do
    user = users(:regular)
    user.email_address = nil

    user.valid?

    assert user.errors.where(:email_address).any? { |error| error.type == :blank }
  end

  test "is invalid with an incorrectly formatted email" do
    user = users(:regular)
    user.email_address = "foobarbaz"

    user.valid?

    assert user.errors.where(:email_address).any? { |error| error.type == :invalid }
  end

  test "correctly formatted email marked as valid" do
    user = users(:regular)
    user.email_address = "foobarbaz@email.com"

    user.valid?

    assert_not user.errors.where(:email_address).any? { |error| error.type == :invalid }
  end

  test "is invalid without a password" do
    user = users(:regular)
    user.password = nil

    user.valid?

    assert user.errors.where(:password).any? { |error| error.type == :blank }
  end

  test "is valid with all required attributes" do
    user = users(:regular)

    assert user.valid?
  end

  test "outputs the correct full name" do
    assert_equal "Test User", users(:regular).full_name
  end

  test "it has an email search method" do
    assert_respond_to User, :search_email_address
  end

  test "email search returns matching results" do
    assert_equal User.search_email_address("test").count, 1
    assert_equal User.search_email_address("example.com").count, 2
  end

  test "email search returns no results when none matching" do
    assert_equal User.search_email_address("foobarbaz.com").count, 0
  end
end

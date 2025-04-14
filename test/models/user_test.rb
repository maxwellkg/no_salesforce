require "test_helper"

class UserTest < ActiveSupport::TestCase

  test "is invalid without a first name" do
    user = users(:regular)
    user.first_name = nil

    user.valid?

    assert user.errors.of_kind? :first_name, :blank
  end

  test "is invalid without a last name" do
    user = users(:regular)
    user.last_name = nil

    user.valid?

    assert user.errors.of_kind? :last_name, :blank
  end

  test "is invalid without an email" do
    user = users(:regular)
    user.email_address = nil

    user.valid?

    assert user.errors.of_kind? :email_address, :blank
  end

  test "is invalid with an incorrectly formatted email" do
    user = users(:regular)
    user.email_address = "foobarbaz"

    user.valid?

    assert user.errors.of_kind? :email_address, :invalid
  end

  test "correctly formatted email marked as valid" do
    user = users(:regular)
    user.email_address = "foobarbaz@email.com"

    user.valid?

    assert_not user.errors.of_kind? :email_address, :invalid
  end

  test "is invalid with a non-unique email address" do
    user = users(:regular).dup

    user.valid?

    assert user.errors.of_kind? :email_address, :taken
  end

  test "it normalizes the email" do
    u = users(:regular)
    u.update(email_address: "NEW@email.com")

    assert_equal u.email_address, "new@email.com"
  end

  test "is invalid without a password" do
    user = users(:regular)
    user.password = nil

    user.valid?

    assert user.errors.of_kind? :password, :blank
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
    assert_equal User.search_email_address("example.com").count, 3
  end

  test "email search returns no results when none matching" do
    assert_equal User.search_email_address("foobarbaz.com").count, 0
  end

end

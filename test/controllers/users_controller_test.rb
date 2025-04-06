require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:regular)
  end

  test "should get index" do
    login_as(users(:regular))

    get users_url
    assert_response :success
  end

  test "should get advanced search index" do
    login_as(users(:regular))

    get users_url(email_address: "example.com", fr: 1, mode: "advanced_search")
    assert_response :success
  end

  test "should get new" do
    login_as(users(:regular))

    get new_user_url
    assert_response :success
  end

  test "should create user" do
    login_as(users(:regular))

    assert_difference("User.count") do
      post users_url, params: {
        user: {
          first_name: "Another",
          last_name: "Test",
          email_address: "another@example.com",
          password: "testuserpassword"
        }
      }
    end

    assert_redirected_to user_url(User.last)
  end

  test "should show user" do
    login_as(users(:regular))

    get user_url(@user)
    assert_response :success
  end

  test "should get edit" do
    login_as(users(:regular))

    get edit_user_url(@user)
    assert_response :success
  end

  test "should update user" do
    login_as(users(:regular))

    patch user_url(@user), params: { user: { email_address: "foobar@baz.com" } }
    assert_redirected_to user_url(@user)
  end

  test "should not allow non-admin users to destroy a user" do
    login_as(users(:regular))

    delete user_url(users(:admin))

    assert flash[:error].present?
    assert_response :redirect
  end

  test "should not allow admin users to destroy their own records" do
    admin = users(:admin)

    login_as(admin)

    delete user_url(admin)

    assert flash[:error].present?
    assert_response :redirect
  end

  test "should allow an admin to destroy a non-admin user" do
    login_as(users(:admin))

    assert_difference("User.count", -1) do
      delete user_url(@user)
    end

    assert_redirected_to users_url
  end

  test "should allow an admin user to destroy another admin user" do
    second_admin = User.create!(
      first_name: "Second",
      last_name: "Admin",
      email_address: "second.admin@example.com",
      password: "adminuserpassword"
    )

    login_as(users(:admin))

    assert_difference("User.count", -1) do
      delete user_url(second_admin)
    end

    assert_redirected_to users_url
  end
end

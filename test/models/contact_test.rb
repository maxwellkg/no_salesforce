require "test_helper"

class ContactTest < ActiveSupport::TestCase

  test "is valid with all required attributes" do
    c = contacts(:child_inc_ceo)

    assert c.valid?
  end

  test "is invalid without an account" do
    c = contacts(:child_inc_ceo)
    c.account = nil

    c.valid?

    assert c.errors.of_kind? :account, :blank
  end

  test "is invalid without an email address" do
    c = contacts(:child_inc_ceo)
    c.email_address = nil

    c.valid?

    assert c.errors.of_kind? :email_address, :blank
  end

  test "is invalid with an improperly formatted email address" do
    c = contacts(:child_inc_ceo)
    c.email_address = "foobarbaz"

    c.valid?

    assert c.errors.of_kind? :email_address, :invalid
  end

  test "it normalizes the email address" do
    c = contacts(:child_inc_ceo)
    c.update!(email_address: "CEO@child.com")

    assert_equal c.email_address, "ceo@child.com"
  end

  test "is invalid without a first name" do
    c = contacts(:child_inc_ceo)
    c.first_name = nil

    c.valid?

    assert c.errors.of_kind? :first_name, :blank
  end

  test "is invalid without a last name" do
    c = contacts(:child_inc_ceo)
    c.last_name = nil

    c.valid?

    assert c.errors.of_kind? :last_name, :blank
  end

  test "is valid without a phone number" do
    c = contacts(:child_inc_ceo)
    c.phone_number = nil

    assert c.valid?
  end

  test "is invalid with an invalid phone number" do
    pn = PhoneNumber.new(number: "123456789", country: locations_countries(:united_states))

    c = contacts(:child_inc_ceo)
    c.phone_number = pn

    c.valid?

    assert c.errors.of_kind? :phone_number, :invalid
  end

  test "is valid without a lead source" do
    c = contacts(:child_inc_ceo)
    c.lead_source = nil

    assert c.valid?
  end

  test "is valid without an address" do
    c = contacts(:child_inc_ceo)
    c.address = nil

    assert c.valid?
  end

  test "is invalid when the address is invalid" do
    invalid_address = Address.new(
      street: "555 5th Avenue",
      city: "New York",
      state_region: locations_state_regions(:new_york),
      country: locations_countries(:united_kingdom)
    )

    c = contacts(:child_inc_ceo)
    c.address = invalid_address

    c.valid?

    assert c.errors.of_kind? :address, :invalid    
  end

  test "is invalid without an owner" do
    c = contacts(:child_inc_ceo)
    c.owner = nil

    c.valid?

    assert c.errors.of_kind? :owner, :blank
  end

  test "is valid without a job title" do
    c = contacts(:child_inc_ceo)
    c.job_title = nil

    assert c.valid?
  end

  test "it sets created_by if not already provided on create" do
    Current.stub :user, users(:admin) do
      c = Contact.create!(
        first_name: "Another",
        last_name: "Test",
        email_address: "another.test@email.com",
        account: accounts(:child_inc),
        owner: users(:regular)
      )

      assert_equal c.created_by, users(:admin)
    end
  end

  test "it does not override created_by if provided on create" do
    Current.stub :user, users(:admin) do
      c = Contact.create!(
        first_name: "Another",
        last_name: "Test",
        email_address: "another.test@email.com",
        account: accounts(:child_inc),
        owner: users(:regular),
        created_by: users(:regular)
      )

      assert_equal c.created_by, users(:regular)
    end
  end

  test "it overrides last_updated_by when not already provided on update" do
    Current.stub :user, users(:admin) do
      c = contacts(:child_inc_ceo)
      c.update!(email_address: "ceo@child.com")

      assert_equal c.last_updated_by, users(:admin)
    end
  end

  test "it does not override last_updated_by if already provided on update" do
    Current.stub :user, users(:third) do
      c = contacts(:child_inc_ceo)
      
      assert_changes -> { c.last_updated_by } do
        c.update!(email_address: "ceo@child.com", last_updated_by: users(:admin))
      end

      assert_equal c.last_updated_by, users(:admin)
    end
  end

  test "it outputs the full name correctly" do
    c = contacts(:child_inc_ceo)

    assert_equal c.full_name, "Test Contact"
  end

end

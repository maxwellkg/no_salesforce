require "test_helper"

class PersonTest < ActiveSupport::TestCase

  test "is valid with all required attributes" do
    person = people(:child_inc_ceo)

    assert person.valid?
  end

  test "is invalid without an account" do
    person = people(:child_inc_ceo)
    person.account = nil

    person.valid?

    assert person.errors.of_kind? :account, :blank
  end

  test "is invalid without an email address" do
    person = people(:child_inc_ceo)
    person.email_address = nil

    person.valid?

    assert person.errors.of_kind? :email_address, :blank
  end

  test "is invalid with an improperly formatted email address" do
    person = people(:child_inc_ceo)
    person.email_address = "foobarbaz"

    person.valid?

    assert person.errors.of_kind? :email_address, :invalid
  end

  test "it normalizes the email address" do
    person = people(:child_inc_ceo)
    person.update!(email_address: "CEO@child.com")

    assert_equal person.email_address, "ceo@child.com"
  end

  test "is invalid without a first name" do
    person = people(:child_inc_ceo)
    person.first_name = nil

    person.valid?

    assert person.errors.of_kind? :first_name, :blank
  end

  test "is invalid without a last name" do
    person = people(:child_inc_ceo)
    person.last_name = nil

    person.valid?

    assert person.errors.of_kind? :last_name, :blank
  end

  test "is valid without a phone number" do
    person = people(:child_inc_ceo)
    person.phone_number = nil

    assert person.valid?
  end

  test "is invalid with an invalid phone number" do
    pn = PhoneNumber.new(number: "123456789", country: locations_countries(:united_states))

    person = people(:child_inc_ceo)
    person.phone_number = pn

    person.valid?

    assert person.errors.of_kind? :phone_number, :invalid
  end

  test "is valid without a lead source" do
    person = people(:child_inc_ceo)
    person.lead_source = nil

    assert person.valid?
  end

  test "is valid without an address" do
    person = people(:child_inc_ceo)
    person.address = nil

    assert person.valid?
  end

  test "is invalid when the address is invalid" do
    invalid_address = Address.new(
      street: "555 5th Avenue",
      city: "New York",
      state_region: locations_state_regions(:new_york),
      country: locations_countries(:united_kingdom)
    )

    person = people(:child_inc_ceo)
    person.address = invalid_address

    person.valid?

    assert person.errors.of_kind? :address, :invalid    
  end

  test "is invalid without an owner" do
    person = people(:child_inc_ceo)
    person.owner = nil

    person.valid?

    assert person.errors.of_kind? :owner, :blank
  end

  test "is valid without a job title" do
    person = people(:child_inc_ceo)
    person.job_title = nil

    assert person.valid?
  end

  test "it sets created_by if not already provided on create" do
    Current.stub :user, users(:admin) do
      person = Person.create!(
        first_name: "Another",
        last_name: "Test",
        email_address: "another.test@email.com",
        account: accounts(:child_inc),
        owner: users(:regular)
      )

      assert_equal person.created_by, users(:admin)
    end
  end

  test "it does not override created_by if provided on create" do
    Current.stub :user, users(:admin) do
      person = Person.create!(
        first_name: "Another",
        last_name: "Test",
        email_address: "another.test@email.com",
        account: accounts(:child_inc),
        owner: users(:regular),
        created_by: users(:regular)
      )

      assert_equal person.created_by, users(:regular)
    end
  end

  test "it overrides last_updated_by when not already provided on update" do
    Current.stub :user, users(:admin) do
      person = people(:child_inc_ceo)
      person.update!(email_address: "ceo@child.com")

      assert_equal person.last_updated_by, users(:admin)
    end
  end

  test "it does not override last_updated_by if already provided on update" do
    Current.stub :user, users(:third) do
      person = people(:child_inc_ceo)
      
      assert_changes -> { person.last_updated_by } do
        person.update!(email_address: "ceo@child.com", last_updated_by: users(:admin))
      end

      assert_equal person.last_updated_by, users(:admin)
    end
  end

  test "it outputs the full name correctly" do
    person = people(:child_inc_ceo)

    assert_equal person.full_name, "Test Contact"
  end

end

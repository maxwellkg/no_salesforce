require "test_helper"

class AccountTest < ActiveSupport::TestCase

  test "is is valid with all required attributes" do
    assert accounts(:child_inc).valid?
  end

  test "it is invalid without an owner" do
    acct = accounts(:child_inc)
    acct.owner_id = nil

    acct.valid?

    assert acct.errors.of_kind? :owner, :blank
  end

  test "it is valid without a phone number" do
    acct = accounts(:child_inc)
    acct.phone_number = nil

    assert acct.valid?
  end

  test "it is invalid without a valid phone number" do
    invalid_pn = PhoneNumber.new(number: "123456789", country: locations_countries(:united_states))

    acct = accounts(:child_inc)
    acct.phone_number = invalid_pn

    acct.valid?

    assert acct.errors.of_kind? :phone_number, :invalid
  end
    
  test "it is valid without a billing address" do
    acct = accounts(:child_inc)
    acct.billing_address = nil

    assert acct.valid?
  end

  test "it is invalid if the billing address is invalid" do
    invalid_address = Address.new(
      street: "555 5th Avenue",
      city: "New York",
      state_region: locations_state_regions(:new_york),
      country: locations_countries(:united_kingdom)
    )

    acct = accounts(:child_inc)
    acct.billing_address = invalid_address

    acct.valid?

    assert acct.errors.of_kind? :billing_address, :invalid
  end

  test "it is valid without a shipping address" do
    acct = accounts(:child_inc)
    acct.shipping_address = nil

    assert acct.valid?
  end

  test "it is invalid if the shipping address is invalid" do
    invalid_address = Address.new(
      street: "555 5th Avenue",
      city: "New York",
      state_region: locations_state_regions(:new_york),
      country: locations_countries(:united_kingdom)
    )

    acct = accounts(:child_inc)
    acct.shipping_address = invalid_address

    acct.valid?

    assert acct.errors.of_kind? :shipping_address, :invalid
  end

  test "is is valid without an industry" do
    acct = accounts(:child_inc)
    acct.industry = nil

    assert acct.valid?
  end

  test "it is valid without an account source" do
    acct = accounts(:child_inc)
    acct.account_source = nil

    assert acct.valid?
  end

  test "it sets created_by if not already provided on create" do
    Current.stub :user, users(:admin) do
      acct = Account.create!(
        name: "New Account",
        owner: users(:admin)
      )

      assert_equal acct.created_by, users(:admin)
    end
  end

  test "it does not override created_by if provided on create" do
    Current.stub :user, users(:admin) do
      acct = Account.create!(
        name: "New Account",
        owner: users(:regular),
        created_by: users(:regular)
      )

      assert_equal acct.created_by, users(:regular)
    end
  end

  test "it overrides last_updated_by when not already provided on update" do
    Current.stub :user, users(:admin) do
      acct = accounts(:child_inc)
      acct.update!(annual_revenue: 1_200_000_000)

      assert_equal acct.last_updated_by, users(:admin)
    end
  end

  test "it does not override last_updated_by if already provided on update" do
    Current.stub :user, users(:third) do
      acct = accounts(:parent_ltd)
      
      assert_changes -> { acct.last_updated_by } do
        acct.update!(annual_revenue: 1_200_000_000, last_updated_by: users(:regular))
      end

      assert_equal acct.last_updated_by, users(:regular)
    end
  end
end

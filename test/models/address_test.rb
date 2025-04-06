require "test_helper"

class AddressTest < ActiveSupport::TestCase

  test "is invalid without a country" do
    addr = Address.new(
      street: "555 5th Avenue",
      city: "New York",
      state_region: locations_state_regions(:new_york)
    )

    addr.valid?

    assert addr.errors.of_kind? :country, :blank
  end

  test "is invalid with a state/region not in the country" do
    addr = Address.new(
      street: "555 5th Avenue",
      city: "New York",
      state_region: locations_state_regions(:new_york),
      country: locations_countries(:united_kingdom)
    )

    addr.valid?

    assert addr.errors.of_kind? :state_region, :inclusion
  end

  test "is valid without a street" do
    addr = Address.new(
      city: "New York",
      state_region: locations_state_regions(:new_york),
      country: locations_countries(:united_states)
    )

    assert addr.valid?
  end

  test "is invalid with a street and without a city" do
    addr = Address.new(
      street: "555 5th Avenue",
      state_region: locations_state_regions(:new_york),
      country: locations_countries(:united_states)
    )

    addr.valid?

    assert addr.errors.of_kind? :city, :blank
  end

  test "is valid without a street and city" do
    addr = Address.new(
      state_region: locations_state_regions(:new_york),
      country: locations_countries(:united_states)
    )

    assert addr.valid?
  end

  test "is valid without a state/region" do
    addr = Address.new(
      street: "111 Strand",
      city: "London",
      country: locations_countries(:united_kingdom),
      postal_code: "WC2R 0AP"
    )

    assert addr.valid?
  end

  test "is valid without a postal code" do
    addr = Address.new(
      street: "111 Strand",
      city: "London",
      country: locations_countries(:united_kingdom)
    )

    assert addr.valid?    
  end

  test "is valid with all attributes given" do
    addr = Address.new(
      street: "555 5th Avenue",
      city: "New York",
      state_region: locations_state_regions(:new_york),
      country: locations_countries(:united_states),
      postal_code: 10017
    )

    assert addr.valid?
  end

end

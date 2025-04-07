require "test_helper"

class PhoneNumberTest < ActiveSupport::TestCase

  test "is valid when phonelib says the number is valid" do
    assert phone_numbers(:british).valid?
  end


  test "is invalid without a number" do
    pn = PhoneNumber.new

    pn.valid?

    assert pn.errors.of_kind? :number, :blank
  end

  test "is invalid when phonelib says the number is invalid" do
    pn = PhoneNumber.new(number: "123456789", country: locations_countries(:united_states))

    pn.valid?

    assert pn.errors.of_kind? :number, :invalid
  end

  test "it sets the phone" do
    pn = PhoneNumber.new(number: "408-647-4636")

    assert pn.phone.instance_of? Phonelib::Phone
  end

  test "it sets the phonelib country when country is present" do
    pn = PhoneNumber.new(number: "408-647-4636", country: locations_countries(:united_states))

    assert_equal pn.phone.country, "US"
  end

  test "it derives the country when country is given" do
    pn = PhoneNumber.new(number: "408-647-4636", country: locations_countries(:united_states))

    assert_equal pn.derived_country, locations_countries(:united_states)
  end

  test "it derives the country when phonelib determines" do
    pn = PhoneNumber.create!(number: "+14086474636")

    assert_equal pn.derived_country, locations_countries(:united_states)
  end

  test "derived country is blank when country is provided and phonelib can't determine" do
    pn = PhoneNumber.new(number: "408-647-4636")

    assert_nil pn.derived_country
  end

end

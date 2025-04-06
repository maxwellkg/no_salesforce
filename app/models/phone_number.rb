class PhoneNumber < ApplicationRecord
  belongs_to :country, class_name: "Locations::Country", optional: true

  validates :number, presence: true
  validates :number, phone: { allow_blank: true, country_specifier: -> (pn) { pn.country&.alpha_2 } }

  def phone
    @phone ||= Phonelib.parse(number, country&.alpha_2)
  end

  # if the country is not given, it may be parseable by phonelib
  # if so, return the Locations::Country instance based on the country
  # provided by phonelib

  def derived_country
    return country if country.present?

    phone.country.present? ? Locations::Country.find_by(alpha_2: phone.country) : nil
  end

end

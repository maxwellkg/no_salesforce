class Address < ApplicationRecord
  belongs_to :country, class_name: "Locations::Country"
  belongs_to :state_region, class_name: "Locations::StateRegion", optional: true

  # validate that the state_region (when present) belongs to the same
  # country that the address does
  validate :state_region_must_belong_to_address_country, if: -> (address) { address.state_region.present? }

  validates :city, presence: { message: "must be present when street is given" }, if: -> (address) { address.street.present? }

  has_one :account, touch: true

  private

    def state_region_must_belong_to_address_country
      unless state_region.country == country
        errors.add(:state_region, :inclusion, message: "does not belong to address country")
      end
    end

end

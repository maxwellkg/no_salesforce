class Locations::StateRegion < ApplicationRecord
  belongs_to :type, class_name: "StateRegionType", optional: true
  belongs_to :country

  alias_attribute :abbreviation, :alpha_code
end

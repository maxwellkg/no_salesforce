class Locations::StateRegion < ApplicationRecord
  belongs_to :state_region_type, optional: true
  belongs_to :country
end

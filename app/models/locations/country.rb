class Locations::Country < ApplicationRecord
  has_many :state_regions
end

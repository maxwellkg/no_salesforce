class DealStage < ApplicationRecord
  has_many :deals, inverse_of: :stage
end

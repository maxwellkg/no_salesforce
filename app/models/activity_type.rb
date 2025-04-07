class ActivityType < ApplicationRecord
  has_many :activities, foreign_key: :type_id, inverse_of: :type

  validates :name, presence: true, uniqueness: true
end

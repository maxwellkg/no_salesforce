class ActivitiesContact < ApplicationRecord
  belongs_to :activity
  belongs_to :contact

  validates :contact, uniqueness: { scope: :activity, message: "can only be added to an activity once" }
end

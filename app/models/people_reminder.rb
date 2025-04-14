class PeopleReminder < ApplicationRecord
  belongs_to :reminder
  belongs_to :person

  validates :person, uniqueness: { scope: :reminder, message: "can only be added to a reminder once" }
end

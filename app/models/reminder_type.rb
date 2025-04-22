class ReminderType < ApplicationRecord
  has_many :reminders, foreign_key: :type_id, inverse_of: :type

  validates :name, presence: true, uniqueness: true

  def display_name
    name.titleize
  end
end

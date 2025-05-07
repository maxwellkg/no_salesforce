class ReminderLink < ApplicationRecord
  belongs_to :reminder
  belongs_to :reminder_subject

  validates :reminder_subject_id, uniqueness: { scope: :reminder_id }
end

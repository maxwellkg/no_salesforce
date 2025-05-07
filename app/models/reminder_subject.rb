class ReminderSubject < ApplicationRecord
  include SAL::BasicSearch
  basic_search :name

  delegated_type :source, types: %w[ Account Deal Person ], dependent: :destroy

  has_many :reminder_links
  has_many :reminders, through: :reminder_links
end

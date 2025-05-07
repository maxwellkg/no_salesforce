module Remindable
  extend ActiveSupport::Concern

  included do
    has_one :reminder_subject, as: :source, dependent: :destroy
    has_many :reminders, through: :reminder_subject

    before_create :ensure_reminder_subject
  end

  private

    def ensure_reminder_subject
      build_reminder_subject(name: name) if reminder_subject.blank?
    end

end

REMINDER_TYPES = %w(
  call
  note
  meeting
  email
)

rts = REMINDER_TYPES.map { |rt| { name: rt } }

ReminderType.create!(rts)

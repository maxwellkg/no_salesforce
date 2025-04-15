module RemindersHelper

  def reminder_notes_preview(reminder)
    truncated = Truncato.truncate reminder.notes.to_s, max_length: 100, count_tags: false
    truncated.html_safe
  end
end

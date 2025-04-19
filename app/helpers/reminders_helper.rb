module RemindersHelper

  def reminder_notes_preview(reminder)
    truncated = Truncato.truncate reminder.notes.to_s, max_length: 100, count_tags: false
    truncated.html_safe
  end

  def reminder_assigned_to_id
    @reminder.assigned_to&.id || Current.user.id
  end

  def people_options_for_reminder
    acct = @reminder.logged_to_an_account? ? @reminder.logged_to : @reminder.logged_to.account
    acct.people
  end

end

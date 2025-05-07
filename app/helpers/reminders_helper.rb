module RemindersHelper

  def reminder_notes_preview(reminder)
    return unless reminder.notes.present?

    truncated = Truncato.truncate reminder.notes.to_s, max_length: 100, count_tags: false
    truncated.html_safe
  end

  def reminder_assigned_to_id
    @reminder.assigned_to&.id || Current.user.id
  end

  def related_to_options_for_reminder
    options_from_collection_for_select(
      @reminder.reminder_subjects,
      :id,
      :name,
      @reminder.reminder_subject_ids
    )
  end

  def new_reminder_path_for_subject_ids(*subject_ids)
    new_reminder_path(reminder: { reminder_subject_ids: subject_ids })
  end

  def new_reminder_path_for_resource(resource)
    new_reminder_path_for_subject_ids(resource.reminder_subject.id)
  end

end

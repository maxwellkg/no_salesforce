module ResourcesHelper

  def resource_type_display(resource)
    resource.class.to_s
  end

  def resource_has_past_due_reminders?(resource)
    resource.reminders.past_due.any?
  end

  def past_due_reminders_collection(resource)
    resource.reminders.past_due.ordered.with_rich_text_notes
  end

  def resource_has_upcoming_reminders?(resource)
    resource.reminders.upcoming.any?
  end

  def upcoming_reminders_collection(resource)
    resource.reminders.open.ordered.with_rich_text_notes
  end  

  def resource_has_completed_reminders?(resource)
    resource.reminders.complete.any?
  end

  def completed_reminders_collection(resource)
    resource.reminders.complete.ordered.with_rich_text_notes
  end

  def render_reminders_partial(collection)
    render partial: "reminders/preview", collection: collection, as: :reminder
  end

  def phone_display(phone_number)
    return if phone_number.nil?

    # use the international display provided by Phonelib
    phone_to phone_number.phone.full_international
  end

  def resource_type_emoji(resource)
    case resource
    when Account
      "🏢"
    when Person
      "🧑"
    when Deal
      "🤝"
    end
  end

  def options_for_all_users(selected: nil)
    options_from_collection_for_select(User.all, :id, :full_name, selected)
  end

  def resource_has_reminders?(resource)
    resource.reminders.any?
  end

  def no_reminders_message(resource)
    "No reminders for this #{resource.class.to_s.demodulize.downcase}"
  end  

  def selected_resource_owner(resource)
    owner = resource.owner || Current.user
    owner.id
  end  

end

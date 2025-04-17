module ResourcesHelper

  def resource_type_display(resource)
    resource.class.to_s
  end

  def resource_has_past_due_reminders?(resource)
    resource.reminders.past_due.any?
  end

  def past_due_reminders_collection(resource)
    resource.reminders.past_due.ordered
  end

  def resource_has_upcoming_reminders?(resource)
    resource.reminders.upcoming.any?
  end

  def upcoming_reminders_collection(resource)
    resource.reminders.open.ordered
  end  

  def resource_has_completed_reminders?(resource)
    resource.reminders.complete.any?
  end

  def completed_reminders_collection(resource)
    resource.reminders.complete.ordered
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

end

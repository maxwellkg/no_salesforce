class SAL::Configs::Reminders < SAL::Config

  SEARCHABLES = [
    { label: "Title", search_method: :search_title }
  ]

  FILTERABLES = [
    {
      label: "Account",
      field: :account_id,
      typeahead: true,
      path: :typeaheads_accounts_path,
      options: {
        value_method: :id,
        text_method: :name,
        allow_multiple: true
      }
    },
    {
      label: "Assigned To",
      field: :assigned_to_id,
      typeahead: true,
      path: :typeaheads_users_path,
      options: {
        value_method: :id,
        text_method: :full_name,
        allow_multiple: true
      }
    },
    {
      label: "Type",
      field: :type_id,
      klass: ReminderType,
      options: {
        collection: Proc.new { ReminderType.order(:name) },
        value_method: :id,
        text_method: :display_name,
        allow_multiple: true
      }
    },    
    {
      label: "Occurring At",
      field: :occurring_at
    }
  ]

  def klass
    Reminder
  end

  def countable
    "reminders"
  end

  def include_for_advanced_search
    [:assigned_to, :account, :type]
  end

  def show_new_resource_button?
    false
  end

end

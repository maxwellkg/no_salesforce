class SAL::Configs::People < SAL::Config

  SEARCHABLES = [
    { search_method: :search_full_name, label: "Name" },
    { search_method: :search_email, label: "Email Address" }
  ]

  FILTERABLES = [
    {
      label: "Account",
      field: :account_id,
      klass: Account,
      typeahead: true,
      path: :typeaheads_accounts_path,
      options: {
        value_method: :id,
        text_method: :name,
        allow_multiple: true
      }
    },
    {
      label: "Lead Source",
      field: :lead_source_id,
      klass: AccountLeadSource,
      options: {
        collection: Proc.new { AccountLeadSource.order(:name) },
        value_method: :id,
        text_method: :name,
        allow_multiple: true
      }
    },
    {
      label: "Assigned To",
      field: :owner_id,
      klass: User,
      typeahead: true,
      path: :typeaheads_users_path,
      options: {
        value_method: :id,
        text_method: :full_name,
        allow_multiple: true
      }
    },
    {
      label: "Created At",
      field: :created_at
    }
  ]

  def klass
    Person
  end

  def countable
    "people"
  end

  def include_for_advanced_search
    [{ address: [:state_region, :country] }, :phone_number]
  end

end

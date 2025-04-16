class SAL::Builders::Account
  include SAL::Builders::Base

  SEARCHABLES = [
    { label: "Name", search_method: :search_name }
  ]

  FILTERABLES = [
    {
      label: "Industry",
      field: :industry_id,
      options: {
        collection: Proc.new { Industry.order(:code) },
        value_method: :id,
        text_method: :name,
        allow_multiple: true
      }
    },
    {
      label: "Account Source",
      field: :account_source_id,
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

  def self.klass
    Account
  end

end

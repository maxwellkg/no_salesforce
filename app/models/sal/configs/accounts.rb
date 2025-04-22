class SAL::Configs::Accounts < SAL::Config

  SEARCHABLES = [
    { label: "Name", search_method: :search_name }
  ]

  FILTERABLES = [
    {
      label: "Industry",
      field: :industry_id,
      klass: Industry,
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
      options: {
        collection: Proc.new { User.all },
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
    Account
  end

  def countable
    "accounts"
  end

  def include_for_advanced_search
    [
      :owner,
      { billing_address: [:state_region, :country] },
      { shipping_address: [:state_region, :country] },
      :phone_number,
      :account_source,
      :created_by,
      :last_updated_by
    ]
  end
  
end

class SAL::Configs::Deals < SAL::Config

  SEARCHABLES = [
    { label: "Name", search_method: :search_name }
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
      label: "Stage",
      field: :stage_id,
      klass: DealStage,
      options: {
        collection: Proc.new { DealStage.all },
        value_method: :id,
        text_method: :name,
        allow_multiple: true
      }
    },
    {
      label: "Source",
      field: :source_id,
      klass: AccountLeadSource,
      options: {
        collection: Proc.new { AccountLeadSource.order(:name) },
        value_method: :id,
        text_method: :name,
        allow_multiple: true
      }
    },
    {
      lable: "Close Date",
      field: :close_date
    },
    {
      label: "Created At",
      field: :created_at
    }
  ]

  def klass
    Deal
  end

  def countable
    "deals"
  end

  def include_for_advanced_search
    [:owner, :stage, :source]
  end



end

class SAL::Configs::Accounts < SAL::Config

  def klass
    Account
  end

  def countable
    "accounts"
  end

  def allowable_modes
    [:advanced_search]
  end

  def default_mode
    :advanced_search
  end

  SEARCHABLE_FIELDS = [
    { label: "Name", search_method: :search_name }
  ]

  FILTERABLE_FIELDS = [
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

  SETTINGS = {
    displayable: {
      "name" => {
        display_name: "Name",
        show_by_default: true,
        result_options: {
          display_transformation: -> (account) { link_to account.name, account, data: { turbo: false } }
        }
      },
      "owner.id" => {
        display_name: "Owner",
        show_by_default: true,
        result_options: {
          display_transformation: -> (account) { link_to account.owner.full_name, account.owner, data: { turbo: false } }
        }
      },
      "billing_address.id" => {
        display_name: "Billing Address",
        show_by_default: false,
        result_options: {
          display_transformation: -> (account) { account.billing_address&.display_address }
        }
      },
      "shipping_address.id" => {
        display_name: "Shipping Address",
        show_by_default: false,
        result_options: {
          display_transformation: -> (account) { account.shipping_address&.display_address }
        }
      },      
      "phone_number.id" => {
        display_name: "Phone Number",
        show_by_default: false,
        result_options: {
          display_transformation: -> (account) { phone_to account.phone_number.number, account.phone_number.phone.full_international }
        }
      },
      "description" => {
        display_name: "Description",
        show_by_default: false
      },
      "annual_revenue" => {
        display_name: "Annual Revenue",
        show_by_default: false,
        result_options: {
          display_transformation: -> (account) { number_to_currency account.annual_revenue, precision: 0 }
        }
      },
      "number_of_employees" => {
        display_name: "Number of Employees",
        show_by_default: false,
        result_options: {
          display_transformation: -> (account) { number_with_delimiter account.number_of_employees }
        }
      },
      "industry.name" => {
        display_name: "Industry",
        show_by_default: false
      },
      "website" => {
        display_name: "Website",
        show_by_default: false
      },
      "incorporation_date" => {
        display_name: "Incorporation Date",
        show_by_default: false
      },
      "account_source.name" => {
        display_name: "Account Source",
        show_by_default: false
      },
      "last_activity_at" => {
        display_name: "Last Activity At",
        show_by_default: false
      }
    },
    searchable: {
      "name" => {
        display_name: "Name",
        search_method: :search_name
      }
    }
  }

end

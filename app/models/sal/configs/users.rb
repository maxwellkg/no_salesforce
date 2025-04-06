class SAL::Configs::Users < SAL::Config

  def klass
    User
  end

  def countable
    "users"
  end

  def allowable_modes
    [:advanced_search]
  end

  def default_mode
    :advanced_search
  end

  SETTINGS = {
    displayable: {
      "first_name" => {
        display_name: "Name",
        show_by_default: true,
        result_options: {
          display_transformation: -> (user) { link_to user.full_name, user, data: { turbo: false } }
        }
      },
      "email_address" => {
        display_name: "Email",
        show_by_default: true
      },
      "job_title" => {
        display_name: "Job Title",
        show_by_default: false
      },
      "created_by" => {
        display_name: "Created By",
        show_by_default: false,
        result_options: {
          display_transformation: -> (user) { link_to user.full_name, user, data: { turbo: false } }
        }
      }
    },
    searchable: {
      "email_address" => {
        display_name: "Email",
        search_method: :search_email_address
      }
    },
=begin
    filterable: {
      "created_by.id" => {
        display_name: "Created By",
        typeahead: true,
        path: :typeaheads_users_path,
        options: {
          value_method: :id,
          text_method: :full_name,
          allow_multiple: true
        }
      },
      "last_updated_by.id" => {
        display_name: "Last Updated By",
        typeahead: true,
        path: :typeaheads_users_path,
        options: {
          value_method: :id,
          text_method: :full_name,
          allow_multiple: true
        }
      }
    }
=end
  }

end

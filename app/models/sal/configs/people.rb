class SAL::Configs::People < SAL::Config

  def klass
    Person
  end

  def countable
    "people"
  end

  def allowable_modes
    [:advanced_search]
  end

  def default_mode
    :advanced_search
  end

  SEARCHABLE_FIELDS = [
    { search_method: :search_full_name }
  ]

  SETTINGS = {
    display_force_includes: [:phone_number],
    displayable: {
      "first_name" => {
        display_name: "Name",
        show_by_default: true,
        result_options: {
          display_transformation: -> (person) { link_to person.full_name, person, data: { turbo: false } }
        }
      },
      "owner.id" => {
        display_name: "Owner",
        show_by_default: true,
        result_options: {
          display_transformation: -> (account) { link_to account.owner.full_name, account.owner, data: { turbo: false } }
        }
      },
      "email_address" => {
        display_name: "Email Address",
        show_by_default: true
      },
      "job_title" => {
        display_name: "Job Title",
        show_by_default: false
      },
      "address.id" => {
        display_name: "Address",
        show_by_default: false,
        result_options: {
          display_transformation: -> (contact) { contact.address&.display_address }
        }
      }, 
      "phone_number.id" => {
        display_name: "Phone Number",
        show_by_default: true,
        result_options: {
          display_transformation: -> (person) { phone_to person.phone_number&.number, person.phone_number&.phone&.full_international }
        }
      },
      "lead_source.name" => {
        display_name: "Lead Source",
        show_by_default: false
      },
      "last_activity_at" => {
        display_name: "Last Activity At",
        show_by_default: false
      }
    },
    searchable: {
      "first_name" => {
        display_name: "Name",
        search_method: :search_name
      }
    }
  }

end

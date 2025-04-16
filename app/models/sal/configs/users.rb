class SAL::Configs::Users < SAL::Config

  SEARCHABLES = [
    { search_method: :search_full_name, label: "Name" },
    { search_method: :search_email_address, label: "Email" }
  ]

  def klass
    User
  end

  def countable
    "users"
  end

end

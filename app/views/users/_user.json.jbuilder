json.extract! user, :id, :first_name, :last_name, :email_address, :created_by_id, :created_at, :updated_at
json.url user_url(user, format: :json)

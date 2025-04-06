module UsersHelper

  def user_form_fields
    [:first_name, :last_name, :email_address, :password, :password_confirmation]
  end

  def user_form_field_required?(field)
    if [:password, :password_confirmation].include?(field)
      @user.new_record?
    else
      false
    end
  end

end

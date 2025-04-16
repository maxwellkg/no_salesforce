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

  def link_to_user(user, **opts)
    return if user.nil?

    link_to user.full_name, user_path(user), opts
  end  

end

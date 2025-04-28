module NavbarHelper

  def signin_signout_html_classes
    "block py-2 px-3 text-md md:text-xl text-white hover:text-gray-400 rounded-sm md:bg-transparent md:p-0"
  end

  def navbar_signin_signout
    if authenticated?
      link_to "Logout", session_path, data: { turbo_method: :delete }, class: signin_signout_html_classes
    else
      link_to "Login", new_session_path, class: signin_signout_html_classes
    end
  end

end

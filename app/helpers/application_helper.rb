module ApplicationHelper

  def default_spinner_text
    "loading results..."
  end

  def spinner_text
    @spinner_text || default_spinner_text
  end

end

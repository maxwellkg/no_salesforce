module AccountsHelper

  def address_display(address)
    return if address.nil?

    [
      address.street,
      address.city,
      address.state_region&.abbreviation,
      address.country&.name,
      address.postal_code
    ].compact.join(", ")
  end

  def website_display(url)
    return if url.nil?

    # force to external url
    link_to url, "//#{url}", target: "_blank"
  end

  def incorporation_date_display(incorporation_date)
    incorporation_date&.to_formatted_s(:rfc822)
  end

  def account_has_people?(account)
    account.people.any?
  end

  def account_has_deals?(account)
    account.deals.any?
  end

  def deals_for_account
    @account.deals.order(close_date: :desc)
  end

  def selected_account_owner
    owner = @account.owner || Current.user
    owner.id
  end

end

module DealsHelper

  def deal_close_date_display(deal)
    deal.close_date.to_formatted_s(:rfc822)
  end

  def deal_amount_display(deal)
    number_to_currency(deal.amount, precision: 0)     
  end

end

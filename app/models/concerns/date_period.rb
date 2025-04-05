module DatePeriod

  DATE_WINDOWS = {
    'Past Two Years' => 'p2y',
    'Last Twelve Months' => 'l12m',
    'Last Six Months' => 'l6m',
    'Last Three Months' => 'l3m',
    'Last Month' => 'lm',
    'All Time' => 'at',
    'Custom' => 'c'
  }


  # because trades are always recorded on the first of the month
  # we actually only include the previous n - 1 months
  DATE_WINDOW_PERIODS = {
    'p2y' => 24.months,
    'l12m' => 12.months,
    'l6m' => 6.months,
    'l3m' => 3.months,
    'lm' => 1.month # don't include the first day of the previous month
  }

  def self.period_from_end(end_date, period)
    (end_date-DATE_WINDOW_PERIODS[period]..end_date)
  end

end
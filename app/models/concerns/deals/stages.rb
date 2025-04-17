module Deals::Stages
  extend ActiveSupport::Concern

  included do

    scope :closed_won, -> { joins(:stage).where(stage: { name: CLOSED_WON_STAGE_NAME }) }
    scope :closed_lost, -> { joins(:stage).where(stage: { name: CLOSED_LOST_STAGE_NAME }) }
    scope :closed, -> { closed_won.or(self.closed_lost) }
    scope :open, -> { joins(:stage).where.not(stage: { name: [CLOSED_WON_STAGE_NAME, CLOSED_LOST_STAGE_NAME] }) }
    scope :past_due, -> { open.where(close_date: ...Date.today) }

    def past_due?
      open? && close_date < Date.today
    end

  end

end

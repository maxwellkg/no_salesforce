class Deal < ApplicationRecord
  include PolymorphicSelectable
  include SAL::BasicSearch
  include Deals::Stages
  
  basic_search :name

  belongs_to :account, inverse_of: :deals
  belongs_to :owner, class_name: "User", inverse_of: :deals
  belongs_to :stage, class_name: "DealStage"
  belongs_to :source, class_name: "AccountLeadSource", optional: true

  has_many :reminders, as: :logged_to

  validates :name, presence: true
  validates :close_date, presence: true

  # include created_by and last_updated_by associations and related callbacks
  include UserTracked

  # won deals must have an amount
  validates :amount, presence: true, if: :closed_won?

  CLOSED_WON_STAGE_NAME = "Closed Won".freeze
  CLOSED_LOST_STAGE_NAME = "Closed Lost".freeze

  def closed_won?
    stage.name == CLOSED_WON_STAGE_NAME
  end

  def closed_lost?
    stage.name == CLOSED_LOST_STAGE_NAME
  end

  def closed?
    closed_won? || closed_lost?
  end

  def open?
    !closed?
  end  

end

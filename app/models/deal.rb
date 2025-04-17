class Deal < ApplicationRecord
  belongs_to :account, inverse_of: :deals
  belongs_to :owner, class_name: "User", inverse_of: :deals
  belongs_to :stage, class_name: "OpportunityStage"
  belongs_to :source, class_name: "AccountLeadSource", optional: true

  validates :name, presence: true
  validates :close_date, presence: true
end

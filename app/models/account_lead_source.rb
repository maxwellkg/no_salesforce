class AccountLeadSource < ApplicationRecord
  has_many :accounts, foreign_key: :account_source_id, inverse_of: :account_source
  
  validates :name, presence: true, uniqueness: true
end

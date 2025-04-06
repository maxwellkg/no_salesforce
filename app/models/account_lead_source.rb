class AccountLeadSource < ApplicationRecord
  validates :name, presence: true, uniqueness: true
end

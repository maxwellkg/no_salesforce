class Industry < ApplicationRecord
  has_many :accounts, inverse_of: :industry

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
end

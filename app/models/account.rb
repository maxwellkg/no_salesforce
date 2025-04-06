class Account < ApplicationRecord
  belongs_to :phone_number, optional: true
  validates_associated :phone_number
end

class Account < ApplicationRecord
  include SAL::BasicSearch
  basic_search :name

  include PolymorphicSelectable

  belongs_to :owner, class_name: "User"
  belongs_to :parent, class_name: "Account", optional: true
  belongs_to :phone_number, optional: true
  belongs_to :billing_address, class_name: "Address", optional: true
  belongs_to :shipping_address, class_name: "Address", optional: true

  # include created_by and last_updated_by associations and related callbacks
  include UserTracked

  belongs_to :industry, optional: true, inverse_of: :accounts
  belongs_to :account_source, class_name: "AccountLeadSource", optional: true, inverse_of: :accounts

  has_many :people, inverse_of: :account

  has_many :reminders

  has_many :deals, inverse_of: :account

  validates :name, presence: true

  validates_associated :phone_number, :billing_address, :shipping_address
end

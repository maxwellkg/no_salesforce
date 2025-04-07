class Account < ApplicationRecord
  belongs_to :owner, class_name: "User"
  belongs_to :parent, class_name: self.to_s, optional: true
  belongs_to :phone_number, optional: true
  belongs_to :billing_address, class_name: "Address", optional: true
  belongs_to :shipping_address, class_name: "Address", optional: true

  # include created_by and last_updated_by associations and related callbacks
  include UserTracked

  belongs_to :industry, optional: true
  belongs_to :account_source, class_name: "AccountLeadSource", optional: true

  validates :name, presence: true

  validates_associated :phone_number, :billing_address, :shipping_address
end

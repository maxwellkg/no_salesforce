class Person < ApplicationRecord
  include PolymorphicSelectable

  include SAL::BasicSearch
  basic_search :full_name, :first_name, :last_name

  belongs_to :account, inverse_of: :people
  belongs_to :phone_number, optional: true
  belongs_to :lead_source, class_name: "AccountLeadSource", optional: true
  belongs_to :address, optional: true
  belongs_to :owner, class_name: "User"
  has_and_belongs_to_many :reminders
  
  # include created_by and last_updated_by associations and related callbacks
  include UserTracked

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  validates :email_address, presence: true
  validates :email_address, format: { with: URI::MailTo::EMAIL_REGEXP }, if: -> (user) { user.email_address.present? }
  
  validates :first_name, presence: true
  validates :last_name, presence: true

  validates_associated :phone_number, :address

  def full_name
    "#{first_name} #{last_name}"
  end

  alias_method :name, :full_name

end

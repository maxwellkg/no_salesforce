class User < ApplicationRecord
  include BasicSearch

  include SAL::FieldSetter

  has_secure_password
  has_many :sessions, dependent: :destroy

  belongs_to :created_by, class_name: "User", optional: true
  belongs_to :last_updated_by, class_name: "User", optional: true

  has_many :assigned_reminders, class_name: "Reminder", foreign_key: :assigned_to_id, inverse_of: :assigned_to
  has_many :owned_accounts, class_name: "Account", foreign_key: :owner_id, inverse_of: :owner
  has_many :owned_contacts, class_name: "Person", foreign_key: :owner_id, inverse_of: :owner
  has_many :deals, foreign_key: :owner_id, inverse_of: :owner

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email_address, presence: true, uniqueness: true,
                            format: { with: URI::MailTo::EMAIL_REGEXP }

  basic_search :email_address
  basic_search :full_name, :first_name, :last_name

  def full_name
    "#{first_name} #{last_name}"
  end

end

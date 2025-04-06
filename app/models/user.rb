class User < ApplicationRecord
  include BasicSearch

  include SAL::FieldSetter

  has_secure_password
  has_many :sessions, dependent: :destroy

  belongs_to :created_by, class_name: self.to_s, optional: true
  belongs_to :last_updated_by, class_name: self.to_s, optional: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email_address, presence: true
  validates :email_address, format: { with: URI::MailTo::EMAIL_REGEXP }, if: -> (user) { user.email_address.present? }
  validates :email_address, uniqueness: true

  basic_search :email_address

  def full_name
    "#{first_name} #{last_name}"
  end

end

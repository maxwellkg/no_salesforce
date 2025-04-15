class Reminder < ApplicationRecord
  belongs_to :account
  belongs_to :type, class_name: "ReminderType", inverse_of: :reminders
  belongs_to :assigned_to, class_name: "User"

  # can be logged to an Account, Contact, or Opportunity
  belongs_to :logged_to, polymorphic: true

  has_many :people_reminders
  accepts_nested_attributes_for :people_reminders
  has_many :people, through: :people_reminders

  # include created_by and last_updated_by associations and related callbacks
  include UserTracked

  has_rich_text :notes, store_if_blank: false

  validates :occurring_at, presence: true
  validates :title, presence: true

  validate :logged_to_must_be_of_valid_type
  validate :logged_to_belongs_to_the_same_account
  validate :cannot_be_complete_if_occuring_in_future

  before_validation :attach_account_from_logged_to, if: -> (reminder) { reminder.account.nil? && reminder.changed? }
  before_save :ensure_logged_to_contact_tagged, if: :logged_to_a_contact?
  after_save :update_last_activity_ats

  scope :complete, -> { where(complete: true ) }
  scope :open, -> { where(complete: false) }

  # activities are considered past due when they are still open after their scheduled
  # occurring_at time
  scope :past_due, -> { where(complete: false, occurring_at: ..DateTime.now)}

  # upcoming = not yet complete, but not past due (occurring_at still in the future)
  scope :upcoming, -> { where(complete: false, occurring_at: DateTime.now..) }

  scope :ordered, -> { order(occurring_at: :desc) }

  def incomplete?
    !complete?
  end

  alias_method :open?, :incomplete?

  def occurring_in_future?
    occurring_at > DateTime.now
  end

  def occurring_in_past?
    occurring_at <= DateTime.now
  end

  # activities are considered past due when they are still open after their scheduled
  # occurring_at time
  def past_due?
    occurring_in_past? && incomplete?
  end

  private

    # can be logged to an Account, Person, or Deal

    VALID_LOGGED_TO_TYPES = %w[ Account Person Deal ].freeze

    def logged_to_of_valid_type?
      VALID_LOGGED_TO_TYPES.include?(logged_to_type)
    end

    def logged_to_must_be_of_valid_type
      unless logged_to_of_valid_type?
        errors.add(:logged_to, :invalid, message: "is not of a valid type")
      end
    end

    def logged_directly_to_account?
      logged_to == account
    end

    def logged_to_an_account?
      logged_to_type == "Account"
    end

    def logged_to_a_contact?
      logged_to_type == "Person"
    end

    # if the account has not been directly assigned, assign it to the
    # account attached to the logged_to
    
    def attach_account_from_logged_to
      self.account = logged_to_an_account? ? logged_to : logged_to.account
    end

    # if an activity is logged to a contact, that contact should always be in the list of people
    # attached to the activity

    def ensure_logged_to_contact_tagged
      return if !logged_to_a_contact?

      people.push(logged_to) if !people.include?(logged_to)
    end

    # mark the record as invalid if the account related to the logged_to resource
    # is not the same as the account directly on the activity
    #
    # don't bother with this if the logged_to is not of a valid type

    def logged_to_belongs_to_the_same_account
      return unless logged_to_of_valid_type?

      lt_account = logged_to_an_account? ? logged_to : logged_to.account

      unless lt_account == account
        errors.add(:base, :invalid, message: "accounts don't match")
      end
    end

    # only update the resource's last_activity_at if the activity occured_at is
    # after the resource's current last_activity_at
    #
    # e.g. if we are logging an activity that occurred last week, but there
    # was an activity already logged from yesterday, keep last_activity_at
    # at yesterday's date

    def update_resource_last_activity_at(resource)
      if resource.last_activity_at.nil? || (occurring_at > resource.last_activity_at)
        resource.update!(last_activity_at: occurring_at)
      end
    end

    def update_account_last_activity_at
      update_resource_last_activity_at(account)
    end

    def update_logged_to_last_activity_at
      update_resource_last_activity_at(logged_to)
    end

    # when an activity is logged, the last_activity_at field on related objects
    # should be updated if the new activity occurred at a time after the previous
    # latest activity
    #
    # (note, occurence is not the same as record creation)
    #
    # this should be done on the account and, if the activity is not logged directly
    # to the account, the logged_to resource

    def update_last_activity_ats
      update_account_last_activity_at
      update_logged_to_last_activity_at unless logged_directly_to_account?
    end

    # don't allow the activity to be marked complete if occurring_at is in the future
    # (if the activity is indeed complete, occurring_at should be updated to reflect the
    # actual completion time before marking as complete)

    def cannot_be_complete_if_occuring_in_future
      if complete? && occurring_in_future?
        errors.add(:base, :invalid, message: "cannot be marked complete if occuring_at is in the future")
      end
    end

end

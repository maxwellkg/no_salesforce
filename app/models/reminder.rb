class Reminder < ApplicationRecord
  belongs_to :type, class_name: "ReminderType", inverse_of: :reminders
  belongs_to :assigned_to, class_name: "User"

  has_many :reminder_links
  has_many :reminder_subjects, through: :reminder_links

  # include created_by and last_updated_by associations and related callbacks
  include UserTracked

  has_rich_text :notes, store_if_blank: false

  validates :occurring_at, presence: true
  validates :title, presence: true

  validate :cannot_be_complete_if_occuring_in_future

  before_save :add_related_reminder_subjects
  after_save :update_last_activity_ats, if: :complete?

  scope :complete, -> { where(complete: true ) }
  scope :open, -> { where(complete: false) }

  # activities are considered past due when they are still open after their scheduled
  # occurring_at time
  scope :past_due, -> { where(complete: false, occurring_at: ..DateTime.now)}

  # upcoming = not yet complete, but not past due (occurring_at still in the future)
  scope :upcoming, -> { where(complete: false, occurring_at: DateTime.now..) }

  scope :ordered, -> { order(occurring_at: :desc) }

  include SAL::BasicSearch
  basic_search :title

  def status
    if complete?
      :complete
    elsif occurring_at < DateTime.now
      :past_due
    else
      :upcoming
    end
  end

  def display_status
    status.to_s.titleize
  end

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

  def logged_to_an_account?
    logged_to_type == "Account"
  end

  def logged_to_a_deal?
    logged_to_type == "Deal"
  end

  def logged_to_a_contact?
    logged_to_type == "Person"
  end  

  private

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

    # when an activity is logged, the last_activity_at field on related objects (Account, Deal, Person)
    # should be updated if the new activity occurred at a time after the previous
    # latest activity
    #
    # (note, occurence is not the same as record creation)
    #
    # the last activity at should be updated on the related object, and when the related object
    # is not an account, the related object's account

    def update_last_activity_ats
      reminder_subjects.includes(:source).each do |rs|
        update_resource_last_activity_at(rs.source)

        unless rs.source.instance_of?(Account)
          update_resource_last_activity_at(rs.source.account)
        end
      end
    end

    # don't allow the activity to be marked complete if occurring_at is in the future
    # (if the activity is indeed complete, occurring_at should be updated to reflect the
    # actual completion time before marking as complete)

    def cannot_be_complete_if_occuring_in_future
      if complete? && occurring_in_future?
        errors.add(:base, :invalid, message: "cannot be marked complete if occuring_at is in the future")
      end
    end


    # add relationship to the parent object of any already-specified reminder subjects
    # e.g. if related to a Person, add the relationship to that Person's account

    def add_related_reminder_subjects
      account_subjects = reminder_subjects.includes(:source).filter_map do |rs|
        rs.source.account.reminder_subject unless rs.account?
      end.uniq

      self.reminder_subjects |= account_subjects
    end

end

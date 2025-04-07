class Activity < ApplicationRecord
  belongs_to :account
  belongs_to :type, class_name: "ActivityType", inverse_of: :activities
  belongs_to :assigned_to, class_name: "User"

  # can be logged to an Account, Contact, or Opportunity
  belongs_to :logged_to, polymorphic: true

  has_and_belongs_to_many :contacts, inverse_of: :activities

  # include created_by and last_updated_by associations and related callbacks
  include UserTracked

  has_rich_text :notes

  validates :occurring_at, presence: true
  validates :title, presence: true

  validate :logged_to_belongs_to_the_same_account

  after_save :update_last_activity_ats

  private

    def logged_directly_to_account?
      logged_to == account
    end

    # mark the record as invalid if the account related to the logged_to resource
    # is not the same as the 

    def logged_to_belongs_to_the_same_account
      lt_account = logged_to.instance_of?(Account) ? logged_to : logged_to.account

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
      if occurring_at > resource.last_activity_at
        resource.update!(last_activity_at: last_activity_at)
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

end

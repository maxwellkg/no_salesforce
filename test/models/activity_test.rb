require "test_helper"

class ActivityTest < ActiveSupport::TestCase

  test "it is valid with all attributes provided" do
    activity = activities(:completed_call)

    assert activity.valid?
  end

  test "it is invalid without an account" do
    # this is a super hacky test because in reality, account_id is
    # a required field in the database, which means it is required to be
    # saved, and therefore even if it gets set to nil later, changed? will
    # be true and the before_validation callback that automatically sets the
    # account would be called and the account would be reset
    #
    # just to be super sure the account validation is in place, though, use a
    # stub just to force a situation where account is nil and changed? is false
    # and check that it works as expected

    activity = activities(:completed_call)
    activity.account = nil

    activity.stub :changed?, false do
      activity.valid?

      assert activity.errors.of_kind? :account, :blank
    end
  end

  test "it sets the account id when logged to an account" do
    activity = Activity.new(
      occurring_at: DateTime.now - 5.days,
      type: activity_types(:call),
      title: "Another Call to Discuss Pricing",
      complete: true,
      logged_to: accounts(:child_inc),
      created_by: users(:regular),
      last_updated_by: users(:regular),
      assigned_to: users(:regular)
    )

    assert_changes -> { activity.account }, from: nil, to: accounts(:child_inc) do
      activity.valid?
    end
  end

  test "it sets the account id when logged to a contact" do
    activity = Activity.new(
      occurring_at: DateTime.now - 5.days,
      type: activity_types(:call),
      title: "Another Call to Discuss Pricing",
      complete: true,
      logged_to: contacts(:child_inc_ceo),
      created_by: users(:regular),
      last_updated_by: users(:regular),
      assigned_to: users(:regular)
    )

    assert_changes -> { activity.account }, from: nil, to: accounts(:child_inc) do
      activity.valid?
    end
  end

  test "it updates account.last_activity_at when logged to an account" do
    occurring_at = Time.now - 1.minute

    activity = Activity.new(
      occurring_at: occurring_at,
      type: activity_types(:call),
      title: "Another Call to Discuss Pricing",
      complete: true,
      logged_to: accounts(:child_inc),
      created_by: users(:regular),
      last_updated_by: users(:regular),
      assigned_to: users(:regular)
    )

    assert_changes -> { accounts(:child_inc).last_activity_at }, to: occurring_at do
      activity.save!
    end
  end

  test "it updates last_activity_at on contact when logged to a contact" do
    occurring_at = Time.now - 1.minute

    activity = Activity.new(
      occurring_at: occurring_at,
      type: activity_types(:call),
      title: "Another Call to Discuss Pricing",
      complete: true,
      logged_to: contacts(:child_inc_ceo),
      created_by: users(:regular),
      last_updated_by: users(:regular),
      assigned_to: users(:regular)
    )

    assert_changes -> { contacts(:child_inc_ceo).last_activity_at }, to: occurring_at do
      activity.save!
    end
  end

  test "it updates last_activity_at on account when logged to a contact" do
    occurring_at = Time.now - 1.minute

    activity = Activity.new(
      occurring_at: occurring_at,
      type: activity_types(:call),
      title: "Another Call to Discuss Pricing",
      complete: true,
      logged_to: contacts(:child_inc_ceo),
      created_by: users(:regular),
      last_updated_by: users(:regular),
      assigned_to: users(:regular)
    )

    acct = contacts(:child_inc_ceo).account

    assert_changes -> { acct.last_activity_at }, to: occurring_at do
      activity.save!
    end
  end

  test "it correctly determines if logged directly to an account" do
    assert activities(:completed_call_account).send(:logged_directly_to_account?)
  end

  test "it correctly determines if not logged directly to account" do
    assert_not activities(:completed_call).send(:logged_directly_to_account?)
  end

  test "it is invalid if logged_to account doesn't match account" do
    skip_nyi
  end

  test "it is valid if logged_to account matches account" do
    skip_nyi
  end

  test "it is invalid without a type" do
    skip_nyi
  end

  test "it is invalid if not assigned to a user" do
    skip_nyi
  end

  test "it is invalid without occurring_at" do
    skip_nyi
  end

  test "it is invalid without a title" do
    skip_nyi
  end

  test "it is invalid if logged to a class other than Account/Contact/Opportunity" do
    activity = activities(:completed_call)
    activity.logged_to = users(:regular)

    activity.valid?

    assert activity.errors.of_kind? :logged_to, :invalid
  end

  test "past due scope includes incomplete with occurring_at in past" do
    skip_nyi
  end

  test "past due scope excludes incomplete but occurring in future" do
    skip_nyi
  end

  test "past due scope excludes completed but occurred in the past" do
    skip_nyi
  end  

  test "incomplete is true when not completed" do
    skip_nyi
  end

  test "incomplete is false when completed" do
    skip_nyi
  end

  test "open? is the same as incomplete?" do
    skip_nyi
  end

  test "correctly determines whether occuring in the future when indeed occuring in the future" do
    skip_nyi
  end

  test "correctly determines whether occuring in the future when occurred in the past" do
    skip_nyi
  end

  test "correctly determines whether occurred in the past when occurring in the future" do
    skip_nyi
  end

  test "correctly determines whether occurred in the past when indeed occurred in the past" do
    skip_nyi
  end

  test "correctly determines whether past due when open and occuring in the future" do
    skip_nyi
  end

  test "correctly determines whether past due when complete and occurred in the past" do
    skip_nyi
  end

  test "correctly determines whether past due when incomplete and was supposed to occur in the past" do
    skip_nyi
  end

  test "cannot be completed if occuring in the future" do
    skip_nyi
  end

  test "can be marked complete if occurred in the past" do
    skip_nyi
  end

  test "it adds the logged_to contact to the contacts list if not already included" do
    skip_nyi
  end

  test "complete scope includes completed" do
    skip_nyi
  end

  test "complete scope excludes incomplete" do
    skip_nyi
  end

  test "open scope includes incomplete" do
    skip_nyi
  end

  test "open scope excludes complete" do
    skip_nyi
  end

end

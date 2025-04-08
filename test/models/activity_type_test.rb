require "test_helper"

class ActivityTypeTest < ActiveSupport::TestCase

  test "is valid with a unique name" do
    at = ActivityType.new(name: "meeting")

    assert at.valid?
  end

  test "is invalid without a name" do
    at = ActivityType.new

    at.valid?

    assert at.errors.of_kind? :name, :blank
  end

  test "is invalid with a non-unique name" do
    at = ActivityType.new(name: activity_types(:call).name)

    at.valid?

    assert at.errors.of_kind? :name, :taken
  end

end

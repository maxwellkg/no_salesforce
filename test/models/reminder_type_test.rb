require "test_helper"

class ReminderTypeTest < ActiveSupport::TestCase

  test "is valid with a unique name" do
    rt = ReminderType.new(name: "meeting")

    assert rt.valid?
  end

  test "is invalid without a name" do
    rt = ReminderType.new

    rt.valid?

    assert rt.errors.of_kind? :name, :blank
  end

  test "is invalid with a non-unique name" do
    rt = ReminderType.new(name: activity_types(:call).name)

    rt.valid?

    assert rt.errors.of_kind? :name, :taken
  end

end

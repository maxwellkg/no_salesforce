require "test_helper"

class AccountLeadSourceTest < ActiveSupport::TestCase
  
  test "it is valid with a name" do
    source = account_lead_sources(:web)

    assert source.valid?
  end

  test "it is invalid without a name" do
    source = AccountLeadSource.new

    source.valid?

    assert source.errors.of_kind? :name, :blank
  end  

  test "is is invalid with a non-unique name" do
    source = AccountLeadSource.new(name: account_lead_sources(:web).name)

    source.valid?

    assert source.errors.of_kind? :name, :taken
  end

end

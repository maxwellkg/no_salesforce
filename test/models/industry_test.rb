require "test_helper"

class IndustryTest < ActiveSupport::TestCase

  test "is valid with all required attributes" do
    assert industries(:agriculture).valid?
  end
  
  test "is invalid without a code" do
    ag = industries(:agriculture)
    ag.code = nil

    ag.valid?

    assert ag.errors.kind_of? :code, :blank
  end

  test "is invalid wit a non-unique code" do
    duplicate = Industry.new(code: industries(:agriculture).code, name: "Some other name")

    dupilcate.valid?

    assert duplicate.errors.kind_of?(:code, :taken)
  end

  test "is invalid without a name" do
    ag = industries(:agriculture)
    ag.name = nil

    ag.valid?

    assert ag.errors.kind_of? :name, :blank
  end

end

require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "new users get the customer role" do
    user = create_user

    assert_equal [ "customer" ], user.roles.pluck(:name)
    assert_not user.admin?
  end

  test "changing role swaps the Rolify role" do
    user = create_user

    user.update!(role: "admin")

    assert_equal [ "admin" ], user.reload.roles.pluck(:name)
    assert user.admin?
  end

  test "invalid role is rejected without touching existing roles" do
    user = create_user(role: "admin")

    assert_not user.update(role: "owner")
    assert_equal [ "admin" ], user.reload.roles.pluck(:name)
  end
end

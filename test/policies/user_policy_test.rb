require "test_helper"

class UserPolicyTest < ActiveSupport::TestCase
  test "only admin can manage users" do
    customer = create_user
    admin = create_user(role: "admin")

    %i[index? show? create? update? destroy?].each do |action|
      assert_not UserPolicy.new(nil, User).public_send(action)
      assert_not UserPolicy.new(customer, User).public_send(action)
      assert UserPolicy.new(admin, User).public_send(action)
    end
  end
end

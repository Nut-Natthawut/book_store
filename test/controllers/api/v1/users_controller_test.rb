require "test_helper"

class Api::V1::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create_user(role: "admin")
    @customer = create_user
    sign_in @admin
  end

  test "index returns users with their role" do
    get api_v1_users_path, as: :json

    assert_response :success
    assert_equal [ "admin", "customer" ], response.parsed_body.pluck("role")
  end

  test "show does not leak the password hash" do
    get api_v1_user_path(@customer), as: :json

    assert_response :success
    assert_equal({ "id" => @customer.id, "email" => @customer.email, "role" => "customer" }, response.parsed_body)
  end

  test "create makes a new user with the given role" do
    assert_difference "User.count", 1 do
      post api_v1_users_path, params: { user: { email: "new@example.com", password: SecureRandom.hex(12), role: "admin" } },
                              as: :json
    end

    assert_response :created
    assert User.find_by(email: "new@example.com").admin?
  end

  test "create with a taken email returns 422" do
    assert_no_difference "User.count" do
      post api_v1_users_path, params: { user: { email: @customer.email, password: SecureRandom.hex(12) } }, as: :json
    end

    assert_response :unprocessable_entity
  end

  test "update can promote another user" do
    patch api_v1_user_path(@customer), params: { user: { role: "admin" } }, as: :json

    assert_response :success
    assert @customer.reload.admin?
  end

  test "update with an invalid email returns 422" do
    patch api_v1_user_path(@customer), params: { user: { email: "not-an-email" } }, as: :json

    assert_response :unprocessable_entity
  end

  test "admin cannot demote themselves" do
    patch api_v1_user_path(@admin), params: { user: { role: "customer" } }, as: :json

    assert_response :unprocessable_entity
    assert @admin.reload.admin?
  end

  test "destroy deletes another user" do
    assert_difference "User.count", -1 do
      delete api_v1_user_path(@customer), as: :json
    end

    assert_response :no_content
  end

  test "admin cannot delete themselves" do
    assert_no_difference "User.count" do
      delete api_v1_user_path(@admin), as: :json
    end

    assert_response :unprocessable_entity
  end
end

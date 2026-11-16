require "test_helper"

class ApiAuthorizationTest < ActionDispatch::IntegrationTest
  test "guest gets 401" do
    get api_v1_books_path, as: :json

    assert_response :unauthorized
  end

  test "customer can read but not write" do
    sign_in create_user

    get api_v1_books_path, as: :json
    assert_response :success

    post api_v1_categories_path, params: { category: { name: "New" } }, as: :json
    assert_response :forbidden

    get api_v1_users_path, as: :json
    assert_response :forbidden
  end

  test "admin can write" do
    sign_in create_user(role: "admin")

    post api_v1_categories_path, params: { category: { name: "New" } }, as: :json

    assert_response :created
  end

  test "login returns the user's role" do
    password = SecureRandom.hex(12)
    user = User.create!(email: "api-#{SecureRandom.hex(4)}@example.com", password: password, role: "admin")

    post api_v1_session_path, params: { email: user.email, password: password }, as: :json

    assert_response :success
    assert_equal({ "id" => user.id, "email" => user.email, "role" => "admin" }, response.parsed_body["user"])
  end
end

require "test_helper"

class Api::V1::SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @password = SecureRandom.hex(12)
    @user = User.create!(email: "session-#{SecureRandom.hex(4)}@example.com", password: @password)
  end

  test "new gives a CSRF token without logging in" do
    get new_api_v1_session_path, as: :json

    assert_response :success
    assert response.parsed_body["csrf_token"].present?
  end

  test "login with the right password signs the user in" do
    post api_v1_session_path, params: { email: @user.email, password: @password }, as: :json

    assert_response :success
    get api_v1_books_path, as: :json
    assert_response :success
  end

  test "login with a wrong password returns 401" do
    post api_v1_session_path, params: { email: @user.email, password: "wrong-#{@password}" }, as: :json

    assert_response :unauthorized
    assert_equal [ "อีเมลหรือรหัสผ่านไม่ถูกต้อง" ], response.parsed_body["errors"]
  end

  test "login with an unknown email returns 401" do
    post api_v1_session_path, params: { email: "nobody@example.com", password: @password }, as: :json

    assert_response :unauthorized
  end

  test "logout signs the user out" do
    sign_in @user

    delete api_v1_session_path, as: :json
    assert_response :no_content

    get api_v1_books_path, as: :json
    assert_response :unauthorized
  end
end

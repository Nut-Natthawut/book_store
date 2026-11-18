require "test_helper"

class Api::V1::MarketsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @market = Market.create!(name: "Central")
    sign_in create_user(role: "admin")
  end

  test "index returns every market" do
    get api_v1_markets_path, as: :json

    assert_response :success
    assert_equal [ { "id" => @market.id, "name" => "Central" } ], response.parsed_body
  end

  test "show returns one market" do
    get api_v1_market_path(@market), as: :json

    assert_response :success
    assert_equal "Central", response.parsed_body["name"]
  end

  test "create saves the market and returns 201" do
    assert_difference "Market.count", 1 do
      post api_v1_markets_path, params: { market: { name: "Siam" } }, as: :json
    end

    assert_response :created
  end

  test "create with a blank name returns 422" do
    assert_no_difference "Market.count" do
      post api_v1_markets_path, params: { market: { name: "" } }, as: :json
    end

    assert_response :unprocessable_entity
    assert_includes response.parsed_body["errors"], "Name can't be blank"
  end

  test "update renames the market" do
    patch api_v1_market_path(@market), params: { market: { name: "Central World" } }, as: :json

    assert_response :success
    assert_equal "Central World", @market.reload.name
  end

  test "update with a blank name returns 422" do
    patch api_v1_market_path(@market), params: { market: { name: "" } }, as: :json

    assert_response :unprocessable_entity
    assert_equal "Central", @market.reload.name
  end

  test "destroy deletes the market and returns 204" do
    assert_difference "Market.count", -1 do
      delete api_v1_market_path(@market), as: :json
    end

    assert_response :no_content
  end

  test "customer cannot delete a market" do
    sign_in create_user

    assert_no_difference "Market.count" do
      delete api_v1_market_path(@market), as: :json
    end

    assert_response :forbidden
  end
end

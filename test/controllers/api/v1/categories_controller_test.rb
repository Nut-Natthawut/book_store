require "test_helper"

class Api::V1::CategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @category = Category.create!(name: "Novel")
    sign_in create_user(role: "admin")
  end

  test "index returns every category" do
    get api_v1_categories_path, as: :json

    assert_response :success
    assert_equal [ { "id" => @category.id, "name" => "Novel" } ], response.parsed_body
  end

  test "show returns one category" do
    get api_v1_category_path(@category), as: :json

    assert_response :success
    assert_equal "Novel", response.parsed_body["name"]
  end

  test "show returns 404 for a missing category" do
    get api_v1_category_path(id: 0), as: :json

    assert_response :not_found
  end

  test "create saves the category and returns 201" do
    assert_difference "Category.count", 1 do
      post api_v1_categories_path, params: { category: { name: "Comics" } }, as: :json
    end

    assert_response :created
    assert_equal "Comics", response.parsed_body["name"]
  end

  test "create with a duplicate name returns 422" do
    assert_no_difference "Category.count" do
      post api_v1_categories_path, params: { category: { name: "NOVEL" } }, as: :json
    end

    assert_response :unprocessable_entity
    assert_includes response.parsed_body["errors"], "Name has already been taken"
  end

  test "update renames the category" do
    patch api_v1_category_path(@category), params: { category: { name: "Fiction" } }, as: :json

    assert_response :success
    assert_equal "Fiction", @category.reload.name
  end

  test "update with a blank name returns 422" do
    patch api_v1_category_path(@category), params: { category: { name: "" } }, as: :json

    assert_response :unprocessable_entity
    assert_equal "Novel", @category.reload.name
  end

  test "destroy deletes an empty category" do
    assert_difference "Category.count", -1 do
      delete api_v1_category_path(@category), as: :json
    end

    assert_response :no_content
  end

  test "destroy refuses a category that still has books" do
    create_book(category: @category)

    assert_no_difference "Category.count" do
      delete api_v1_category_path(@category), as: :json
    end

    assert_response :unprocessable_entity
  end
end

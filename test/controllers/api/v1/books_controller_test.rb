require "test_helper"

class Api::V1::BooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @category = create_category
    @market = Market.create!(name: "API market")
    @book = create_book(title: "Ruby Basics", category: @category, market_ids: [ @market.id ])
    sign_in create_user(role: "admin")
  end

  def valid_params
    { title: "New book", author: "Writer", description: "About something", price: 250,
      category_id: @category.id, market_ids: [ @market.id ] }
  end

  test "index returns books with category and markets" do
    get api_v1_books_path, as: :json

    assert_response :success
    book = response.parsed_body.first
    assert_equal "Ruby Basics", book["title"]
    assert_equal({ "id" => @category.id, "name" => @category.name }, book["category"])
    assert_equal [ { "id" => @market.id, "name" => @market.name } ], book["markets"]
  end

  test "index filters by category and search text" do
    create_book(title: "Thai Cooking")

    get api_v1_books_path(category_id: @category.id), as: :json
    assert_equal [ "Ruby Basics" ], response.parsed_body.pluck("title")

    get api_v1_books_path(q: "cook"), as: :json
    assert_equal [ "Thai Cooking" ], response.parsed_body.pluck("title")
  end

  test "show returns one book" do
    get api_v1_book_path(@book), as: :json

    assert_response :success
    assert_equal @book.id, response.parsed_body["id"]
  end

  test "show returns 404 for a missing book" do
    get api_v1_book_path(id: 0), as: :json

    assert_response :not_found
  end

  test "create saves the book and returns 201" do
    assert_difference "Book.count", 1 do
      post api_v1_books_path, params: { book: valid_params }, as: :json
    end

    assert_response :created
    assert_equal "New book", response.parsed_body["title"]
  end

  test "create with a blank title returns 422 and the errors" do
    assert_no_difference "Book.count" do
      post api_v1_books_path, params: { book: valid_params.merge(title: "") }, as: :json
    end

    assert_response :unprocessable_entity
    assert_includes response.parsed_body["errors"], "Title can't be blank"
  end

  test "create without book params returns 400" do
    post api_v1_books_path, params: {}, as: :json

    assert_response :bad_request
  end

  test "update changes the book" do
    patch api_v1_book_path(@book), params: { book: { price: 300 } }, as: :json

    assert_response :success
    assert_equal 300, @book.reload.price
  end

  test "update with an invalid price returns 422" do
    patch api_v1_book_path(@book), params: { book: { price: -5 } }, as: :json

    assert_response :unprocessable_entity
    assert_equal 100, @book.reload.price
  end

  test "destroy deletes the book and returns 204" do
    assert_difference "Book.count", -1 do
      delete api_v1_book_path(@book), as: :json
    end

    assert_response :no_content
  end
end

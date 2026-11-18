require "test_helper"

class BooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @category = create_category
    @book = create_book(title: "Ruby Basics", category: @category)
  end

  def valid_params
    { title: "New book", author: "Writer", description: "About something", price: 250, category_id: @category.id }
  end

  # --- index ---

  test "index lists every book" do
    other = create_book(title: "Thai Cooking")

    get books_path

    assert_response :success
    assert_select "article.book h2", text: @book.title
    assert_select "article.book h2", text: other.title
  end

  test "index filters by category" do
    create_book(title: "Thai Cooking")

    get books_path(category_id: @category.id)

    assert_select "article.book", count: 1
    assert_select "article.book h2", text: "Ruby Basics"
  end

  test "index searches titles without caring about case" do
    create_book(title: "Thai Cooking")

    get books_path(q: "ruby")

    assert_select "article.book", count: 1
    assert_select "article.book h2", text: "Ruby Basics"
  end

  test "index says when nothing matches" do
    get books_path(q: "no such book")

    assert_select "article.book", count: 0
    assert_select "p", text: "ไม่พบหนังสือ"
  end

  # --- show ---

  test "show displays the book" do
    get book_path(@book)

    assert_response :success
    assert_select "h1", text: @book.title
  end

  # --- new ---

  test "admin sees the new book form" do
    sign_in create_user(role: "admin")

    get new_book_path

    assert_response :success
    assert_select "form"
  end

  # --- create ---

  test "create saves the book and redirects" do
    sign_in create_user(role: "admin")

    assert_difference "Book.count", 1 do
      post books_path, params: { book: valid_params }
    end
    assert_redirected_to book_path(Book.order(:id).last)
    assert_equal "เพิ่มหนังสือแล้ว", flash[:notice]
  end

  test "a blank title shows the form again" do
    sign_in create_user(role: "admin")

    assert_no_difference "Book.count" do
      post books_path, params: { book: valid_params.merge(title: "") }
    end
    assert_response :unprocessable_entity
  end

  test "customer cannot create a book" do
    sign_in create_user

    assert_no_difference "Book.count" do
      post books_path, params: { book: valid_params }
    end
    assert_redirected_to root_path
  end

  # --- update ---

  test "update changes the book and redirects" do
    sign_in create_user(role: "admin")

    patch book_path(@book), params: { book: { title: "Ruby Advanced" } }

    assert_redirected_to book_path(@book)
    assert_equal "Ruby Advanced", @book.reload.title
  end

  test "an invalid price shows the edit form again" do
    sign_in create_user(role: "admin")

    patch book_path(@book), params: { book: { price: 0 } }

    assert_response :unprocessable_entity
    assert_equal 100, @book.reload.price
  end

  # --- destroy ---

  test "destroy removes the book and goes back to the list" do
    sign_in create_user(role: "admin")

    assert_difference "Book.count", -1 do
      delete book_path(@book)
    end
    assert_redirected_to books_path
  end

  test "customer cannot destroy a book" do
    sign_in create_user

    assert_no_difference "Book.count" do
      delete book_path(@book)
    end
  end
end

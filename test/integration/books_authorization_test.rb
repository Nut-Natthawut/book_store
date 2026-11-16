require "test_helper"

class BooksAuthorizationTest < ActionDispatch::IntegrationTest
  setup do
    @book = Book.create!(title: "Test", author: "A", description: "D", price: 100,
                         category: Category.create!(name: "Test category"))
  end

  test "guest can view books but is sent to sign in for new" do
    get books_path
    assert_response :success

    get book_path(@book)
    assert_response :success

    get new_book_path
    assert_redirected_to new_user_session_path
  end

  test "customer is rejected from editing books" do
    sign_in create_user

    get edit_book_path(@book)

    assert_redirected_to root_path
    assert_equal "คุณไม่มีสิทธิ์ทำรายการนี้", flash[:alert]
  end

  test "admin can edit books" do
    sign_in create_user(role: "admin")

    get edit_book_path(@book)

    assert_response :success
  end
end

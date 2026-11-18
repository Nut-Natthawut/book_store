require "test_helper"

# admin_access_test.rb เช็คแค่ว่าใครเข้าหน้าไหนได้ ไฟล์นี้เช็คว่าหน้า admin แสดงข้อมูลและทำงานถูก
class AdminResourcesTest < ActionDispatch::IntegrationTest
  setup do
    sign_in create_user(role: "admin")
    @category = Category.create!(name: "Admin category")
    @market = Market.create!(name: "Admin market")
    @book = create_book(title: "Admin book", category: @category, market_ids: [ @market.id ])
  end

  test "index pages list the records" do
    get admin_books_path
    assert_select "td", text: "Admin book"

    get admin_categories_path
    assert_select "td", text: "Admin category"

    get admin_markets_path
    assert_select "td", text: "Admin market"
  end

  test "book show page lists its category and markets" do
    get admin_book_path(@book)

    assert_response :success
    assert_select "td", text: "Admin market"
  end

  test "category and market show pages list their books" do
    [ admin_category_path(@category), admin_market_path(@market) ].each do |path|
      get path
      assert_response :success
      assert_select "a", text: "Admin book"
    end
  end

  test "user show page displays the role" do
    customer = create_user

    get admin_user_path(customer)

    assert_response :success
    assert_select "td", text: "customer"
  end

  test "admin can create a book" do
    assert_difference "Book.count", 1 do
      post admin_books_path, params: { book: { title: "Created in admin", author: "A", description: "D", price: 50,
                                               category_id: @category.id, market_ids: [ @market.id ] } }
    end

    assert_redirected_to admin_book_path(Book.order(:id).last)
  end

  test "deleting an empty category works" do
    empty = Category.create!(name: "Empty category")

    assert_difference "Category.count", -1 do
      delete admin_category_path(empty)
    end

    assert_redirected_to admin_categories_path
    assert_equal "ลบหมวดหมู่แล้ว", flash[:notice]
  end

  test "deleting a category with books shows why it failed" do
    assert_no_difference "Category.count" do
      delete admin_category_path(@category)
    end

    assert_redirected_to admin_categories_path
    assert flash[:alert].present?
  end
end

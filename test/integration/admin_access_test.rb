require "test_helper"

class AdminAccessTest < ActionDispatch::IntegrationTest
  test "guest is sent to sign in" do
    get admin_root_path

    assert_redirected_to new_user_session_path
  end

  test "customer is rejected from every admin page" do
    sign_in create_user

    [ admin_root_path, admin_books_path, admin_categories_path, admin_markets_path, admin_users_path ].each do |path|
      get path
      assert_redirected_to root_path, "expected #{path} to be rejected"
      assert_equal "คุณไม่มีสิทธิ์ทำรายการนี้", flash[:alert]
    end
  end

  test "admin can open every admin page" do
    sign_in create_user(role: "admin")

    [ admin_root_path, admin_books_path, admin_categories_path, admin_markets_path, admin_users_path ].each do |path|
      get path
      assert_response :success, "expected #{path} to load"
    end
  end

  test "admin can open every new and edit form" do
    sign_in create_user(role: "admin")
    category = Category.create!(name: "Form test")
    market = Market.create!(name: "Form market")
    book = Book.create!(title: "T", author: "A", description: "D", price: 10, category: category)
    user = create_user

    [ new_admin_book_path, edit_admin_book_path(book), new_admin_category_path, edit_admin_category_path(category),
      new_admin_market_path, edit_admin_market_path(market), new_admin_user_path, edit_admin_user_path(user) ].each do |path|
      get path
      assert_response :success, "expected #{path} to load"
    end
  end

  test "admin can promote a customer" do
    sign_in create_user(role: "admin")
    customer = create_user

    patch admin_user_path(customer), params: { user: { email: customer.email, password: "", password_confirmation: "", role: "admin" } }

    assert_redirected_to admin_user_path(customer)
    assert customer.reload.admin?
  end

  test "admin cannot demote or delete themselves" do
    admin = create_user(role: "admin")
    sign_in admin

    patch admin_user_path(admin), params: { user: { email: admin.email, role: "customer" } }
    assert admin.reload.admin?

    delete admin_user_path(admin)
    assert User.exists?(admin.id)
  end
end

require "test_helper"

class BookPolicyTest < ActiveSupport::TestCase
  test "everyone can browse books" do
    [ nil, create_user, create_user(role: "admin") ].each do |user|
      assert BookPolicy.new(user, Book).index?
      assert BookPolicy.new(user, Book).show?
    end
  end

  test "everyone sees every book in the scope" do
    category = Category.create!(name: "Scope test")
    book = Book.create!(title: "T", author: "A", description: "D", price: 10, category: category)

    [ nil, create_user, create_user(role: "admin") ].each do |user|
      assert_includes BookPolicy::Scope.new(user, Book).resolve, book
    end
  end

  test "only admin can create, update and destroy books" do
    admin = create_user(role: "admin")

    [ nil, create_user ].each do |user|
      policy = BookPolicy.new(user, Book)
      assert_not policy.create?
      assert_not policy.update?
      assert_not policy.destroy?
    end

    policy = BookPolicy.new(admin, Book)
    assert policy.create?
    assert policy.update?
    assert policy.destroy?
  end
end

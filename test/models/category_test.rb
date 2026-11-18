require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  test "name is required" do
    category = Category.new(name: "")

    assert_not category.valid?
    assert_includes category.errors[:name], "can't be blank"
  end

  test "name must be unique, ignoring case" do
    Category.create!(name: "Novel")

    category = Category.new(name: "novel")

    assert_not category.valid?
    assert_includes category.errors[:name], "has already been taken"
  end

  test "a category without books can be destroyed" do
    category = create_category

    assert category.destroy
    assert_not Category.exists?(category.id)
  end

  test "a category that still has books cannot be destroyed" do
    category = create_category
    create_book(category: category)

    assert_not category.destroy
    assert Category.exists?(category.id)
    assert_not_empty category.errors[:base]
  end
end

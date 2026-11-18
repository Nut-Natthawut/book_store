require "test_helper"

class BookTest < ActiveSupport::TestCase
  test "a book with all fields is valid" do
    assert create_book.persisted?
  end

  test "title, author and description are required" do
    book = Book.new

    assert_not book.valid?
    assert_includes book.errors[:title], "can't be blank"
    assert_includes book.errors[:author], "can't be blank"
    assert_includes book.errors[:description], "can't be blank"
  end

  test "a book needs a category" do
    book = Book.new(title: "T", author: "A", description: "D", price: 10)

    assert_not book.valid?
    assert_includes book.errors[:category], "must exist"
  end

  test "price must be more than 0 and less than 100,000,000" do
    book = create_book

    [ nil, 0, -1, 100_000_000 ].each do |price|
      book.price = price
      assert_not book.valid?, "expected price #{price.inspect} to be rejected"
    end

    [ 0.01, 99_999_999 ].each do |price|
      book.price = price
      assert book.valid?, "expected price #{price.inspect} to be accepted"
    end
  end

  test "saving with market_ids links the markets" do
    market_a = Market.create!(name: "Market A")
    market_b = Market.create!(name: "Market B")

    book = create_book(market_ids: [ market_a.id, market_b.id ])

    assert_equal [ market_a, market_b ].sort_by(&:id), book.reload.markets.order(:id).to_a
  end

  test "an unknown market id makes the book invalid" do
    book = Book.new(title: "T", author: "A", description: "D", price: 10, category: create_category,
                    market_ids: [ 0 ])

    assert_not book.valid?
    assert_includes book.errors[:market_ids], "มีร้านที่ไม่มีอยู่จริง"
  end

  test "a failed update does not change the book's markets" do
    old_market = Market.create!(name: "Old market")
    new_market = Market.create!(name: "New market")
    book = create_book(market_ids: [ old_market.id ])

    assert_not book.update(title: "", market_ids: [ new_market.id ])

    assert_equal [ old_market ], book.reload.markets.to_a
  end

  test "destroying a book removes its market links" do
    book = create_book(market_ids: [ Market.create!(name: "Linked market").id ])

    assert_difference "BookMarket.count", -1 do
      book.destroy
    end
  end
end

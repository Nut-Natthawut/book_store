require "test_helper"

class MarketTest < ActiveSupport::TestCase
  test "name is required" do
    market = Market.new(name: "")

    assert_not market.valid?
    assert_includes market.errors[:name], "can't be blank"
  end

  test "name must be unique, ignoring case" do
    Market.create!(name: "Central")

    market = Market.new(name: "CENTRAL")

    assert_not market.valid?
    assert_includes market.errors[:name], "has already been taken"
  end

  test "destroying a market removes its book links but keeps the books" do
    market = Market.create!(name: "Closing market")
    book = create_book(market_ids: [ market.id ])

    assert_difference "BookMarket.count", -1 do
      market.destroy
    end
    assert Book.exists?(book.id)
  end

  test "the same book cannot be linked to the same market twice" do
    market = Market.create!(name: "Only once")
    book = create_book(market_ids: [ market.id ])

    duplicate = BookMarket.new(book: book, market: market)

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:book_id], "has already been taken"
  end
end

class BookMarket < ApplicationRecord
  belongs_to :book
  belongs_to :market

  validates :book_id, uniqueness: { scope: :market_id }
end

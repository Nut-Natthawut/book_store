class Market < ApplicationRecord
  has_many :book_markets, dependent: :destroy
  has_many :books, through: :book_markets

  validates :name, presence: true
end

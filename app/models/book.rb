class Book < ApplicationRecord
  belongs_to :category
  has_many :book_markets, dependent: :destroy
  has_many :markets, through: :book_markets

  validates :title, :author, :description, presence: true
  validates :price, numericality: { greater_than: 0 }
end

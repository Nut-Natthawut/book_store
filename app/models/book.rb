class Book < ApplicationRecord
  belongs_to :category

  validates :title, :author, :description, presence: true
  validates :price, numericality: { greater_than: 0 }
  
end

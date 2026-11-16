class BookMarket < ApplicationRecord
  def self.ransackable_attributes(_auth_object = nil)
    %w[book_id market_id]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end

  belongs_to :book
  belongs_to :market

  validates :book_id, uniqueness: { scope: :market_id }
end

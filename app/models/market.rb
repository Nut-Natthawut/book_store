class Market < ApplicationRecord
  def self.ransackable_attributes(_auth_object = nil)
    %w[id name created_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end

  has_many :book_markets, dependent: :destroy
  has_many :books, through: :book_markets

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end

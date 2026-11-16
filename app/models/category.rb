class Category < ApplicationRecord
  def self.ransackable_attributes(_auth_object = nil)
    %w[id name created_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  has_many :books, dependent: :restrict_with_error
end

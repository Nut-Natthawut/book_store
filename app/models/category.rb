class Category < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  has_many :books, dependent: :restrict_with_error
end

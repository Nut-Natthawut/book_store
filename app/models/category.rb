class Category < ApplicationRecord
  validates :name, presence: true
  has_many :books, dependent: :restrict_with_error

end

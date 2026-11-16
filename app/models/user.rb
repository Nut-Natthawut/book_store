class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :role, inclusion: { in: %w[customer admin] }

  def admin?
    role == "admin"
  end
end

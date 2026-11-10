class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :role, inclusion: { in: %w[customer admin] }

  def admin?
    role == "admin"
  end
end
